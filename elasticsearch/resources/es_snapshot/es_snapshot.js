const AWS = require('aws-sdk');

exports.createESSnapshotRepo = function (event, context, callback) {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log("Context is " + JSON.stringify(context));
    let url = 'https://' + process.env.esEndpoint;
    console.log("URL is " + url);

    var endpoint = new AWS.Endpoint(process.env.esEndpoint);
    var request = new AWS.HttpRequest(endpoint, process.env.region);

    request.method = 'PUT';
    request.path = '/_snapshot/logs-es-snapshot-repo';
    request.body = JSON.stringify({
        type: 's3',
        settings: {
            compress: true,
            bucket: process.env.bucketName,
            region: process.env.region,
            role_arn: process.env.roleARN
        }
    });
    request.headers['host'] = process.env.esEndpoint;
    request.headers['Content-Type'] = 'application/json';
    // Content-Length is only needed for DELETE requests that include a request
    // body, but including it for all requests doesn't seem to hurt anything.
    request.headers["Content-Length"] = request.body.length;

    var credentials = new AWS.EnvironmentCredentials('AWS');
    var signer = new AWS.Signers.V4(request, 'es');
    signer.addAuthorization(credentials, new Date());

    var client = new AWS.HttpClient();
    client.handleRequest(request, null, function (response) {
        console.log(response.statusCode + ' ' + response.statusMessage);
        callback(null, response.statusCode);
        return "Success";
    }, function (error) {
        console.log('Error: ' + error);
        callback(Error(error));
        throw (error);
    });
};

exports.createSnapshot = function (event, context, callback) {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log("Event is " + JSON.stringify(event));

    var endpoint = new AWS.Endpoint(process.env.esEndpoint);
    var request = new AWS.HttpRequest(endpoint, process.env.region);
    let date = new Date().toISOString().replace(/\..+/, '').replace(/[:\-T]/g, '');
    let snapshotName = `snapshot_${date}`;
    request.method = 'PUT';
    request.path = '/_snapshot/logs-es-snapshot-repo/' + snapshotName;
    console.log("Request Path: " + request.path);
    request.body = JSON.stringify({type: 'S3'});
    request.headers['host'] = process.env.esEndpoint;
    request.headers['Content-Type'] = 'application/json';
    request.headers["Content-Length"] = request.body.length;

    var credentials = new AWS.EnvironmentCredentials('AWS');
    var signer = new AWS.Signers.V4(request, 'es');
    signer.addAuthorization(credentials, new Date());

    var client = new AWS.HttpClient();
    client.handleRequest(request, null, function (response) {
        console.log(response.statusCode + ' ' + response.statusMessage);
        callback(null, response.statusCode);
        return "Success";
    }, function (error) {
        console.log('Error: ' + error);
        callback(Error(error));
        throw (error);
    });
};

exports.deleteIndices = function (event, context, callback) {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log("Event is " + JSON.stringify(event));
    var endpoint = new AWS.Endpoint(process.env.esEndpoint);
    var request = new AWS.HttpRequest(endpoint, process.env.region);
    var retentionDays = parseInt(process.env.retentionDays);
    console.log("Cleaning up Alcyon logs");
    deleteIndex (endpoint, request, retentionDays, ".");
    console.log("Cleaning up Jaeger logs");
    deleteIndex (endpoint, request, retentionDays, "-");
    console.log("Cleaning up other logs");
    deleteIndex (endpoint, request, retentionDays, "");
    return "done";
};

function deleteIndex (endpoint, request, retentionDays, separator) {
    for (let i = retentionDays; i < retentionDays + 30; i++) {
        let date = new Date();
        date.setDate(date.getDate()-i);
        let indexFilter = "/*" + date.toISOString().split('T')[0].replace(/-/g, separator) + "*";
        console.log('index filter: ' + indexFilter);
        request.method = 'DELETE';
        request.path = indexFilter;
        console.log("Request Path: " + request.path);
        request.body = JSON.stringify({type: 'S3'});
        request.headers['host'] = process.env.esEndpoint;
        request.headers['Content-Type'] = 'application/json';
        request.headers["Content-Length"] = request.body.length;

        let credentials = new AWS.EnvironmentCredentials('AWS');
        let signer = new AWS.Signers.V4(request, 'es');
        signer.addAuthorization(credentials, new Date());

        let client = new AWS.HttpClient();
        client.handleRequest(request, null, function (response) {
            console.log(response.statusCode + ' ' + response.statusMessage);
            var responseBody = '';
            response.on('data', function(chunk) {
                responseBody += chunk;
            });
            response.on('end', function(chunk) {
                console.log('Response body: ' + responseBody);
            });
            return "Success";
        }, function (error) {
            console.log('Error: ' + error);
            throw (error);
        });
    }
}