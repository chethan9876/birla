# Redflex - Infrastructure

## AWS Environments

Different AWS accounts and environments are listed here:
https://redflex.atlassian.net/wiki/spaces/DEVL/pages/146178323/AWS+Cloud+environment

## Infrastructure as Code

We will be using Terraform (v0.10 or greater) to automate provisioning of AWS EC2 instances.

1. Download terraform and add to system path. https://www.terraform.io/
1. Download and install the AWS CLI. https://aws.amazon.com/cli/
1. Ensure all script files (````*.sh````) use LF line ending instead of CRLF.
1. Run ````terraform init```` to download all plugins.
1. Run ````terraform plan```` to confirm changes that will be applied.
1. Run ````terraform apply```` to apply changes.

**NOTE:**  Look at the README file in the subdirectory to see the module specific commands.

## To run unit tests

Run the following commands:
```shell
cd <Path to redflex-infrastructure directory>
docker run --rm -v $(pwd):/root/redflex-infrastructure --entrypoint "/root/redflex-infrastructure/entrypoint.sh" docker.rtsprod.net/common/aws-kubernetes-tools:latest
```
 
## AWS Credentials for Terraform and CLI

We use OKTA SAML login to AWS environments and we don't have local users and access keys in AWS. 
We need to generate AWS access key and secret key as required and it will be valid only for 1 hour.
  
### Okta login for NEW Redflex.com users

Create a ".okta_aws_login_config" file in your home folder with contents from the file in this folder
NOTE: replace your username with first.last@redflex.com

finally you can run the following to authenticate through Okta
 
````bash
docker login docker.rtsprod.net -u redflex
rm -rf ~/.aws/credentials
touch ~/.aws/credentials
docker run -it --rm -v ~/.aws/credentials:/root/.aws/credentials -v ~/.okta_aws_login_config:/root/.okta_aws_login_config docker.rtsprod.net/common/aws-okta:latest --profile ca-sk
````

## Help

1. To find CoreOS AMI owner details: `aws ec2 describe-images --image-id ami-0cb589c5f6134f078`
2. If ````NoCredentialProviders: no valid providers in chain. Deprecated. ```` error comes up, ensure:
    1. AWS login session is live and not timed out
    2. Profile in ````~/.aws/config```` file all inherit from default profile.
3. While using Kafka and related images from Confluent refer to this page to make sure it's community licensed https://docs.confluent.io/platform/current/installation/docker/image-reference.html
