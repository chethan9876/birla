
resource "aws_directory_service_directory" "adconnector_directory" {
  name     = var.activedirectoryname
  password = var.adconnector_password
  size     = var.adconnectorsize
  type     = "ADConnector"

  connect_settings {
    customer_dns_ips  = var.ad_dns
    customer_username = var.adconnector_username
    subnet_ids        = var.subnet_ids
    vpc_id            = var.vpc_id
  }

  tags = {
    Name = ("${var.activedirectoryname}-domaincontroller")
//    Environment = var.environment
//    Client = var.client
//    Application = var.application
}	

  
}




