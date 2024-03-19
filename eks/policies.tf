data "aws_iam_policy_document" "cluster_master_role_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = [
        "eks.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"]
    effect = "Allow"
    resources = [
      "*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name = "${local.prefix}-autoscaler-policy-iam"
  policy = data.aws_iam_policy_document.cluster_autoscaler_policy.json

  tags = {
    Name = "${local.prefix}-aws-iam-policy"
    Client = var.client
    Environment = var.environment
  }
}

data "tls_certificate" "openid_connect_provider_tls_certificate" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list = [
    "sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.openid_connect_provider_tls_certificate.certificates[0].sha1_fingerprint]

  tags = {
    Name = "${local.prefix}-aws-iam-openid"
    Client = var.client
    Environment = var.environment
  }
}


data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      identifiers = [
        aws_iam_openid_connect_provider.openid_connect_provider.arn]
      type = "Federated"
    }
  }
}

data "aws_iam_policy_document" "cluster_worker_node_assume_role_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = [
        "ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
  provider = aws.route53
}

data "aws_iam_policy_document" "cluster_worker_node_base_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"]
    effect = "Allow"
    resources = [
      "*"]
  }
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:Get*"]
    effect = "Allow"
    resources = [
      var.client == "us-govcloud" ? replace(data.aws_route53_zone.root_domain.arn, "aws", "aws-us-gov") : data.aws_route53_zone.root_domain.arn,
      var.client == "us-govcloud" ? replace(var.hosted_zone_arn, "aws", "aws-us-gov") : var.hosted_zone_arn
    ]
  }
}

resource "aws_iam_policy" "cluster_worker_node_base_policy" {
  name = "${local.prefix}-worker-node-base-policy-iam"
  policy = data.aws_iam_policy_document.cluster_worker_node_base_policy.json

  tags = {
    Name = "${local.prefix}-cluster-worker-node-policy"
    Client = var.client
    Environment = var.environment
  }
}

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "aws_loadbalancer_controller_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags"]
    effect = "Allow"
    resources = [
      "*"]
  }
  statement {
    actions = [
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection"]
    effect = "Allow"
    resources = [
      "*"]
  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"]
    effect = "Allow"
    resources = [
      "*"]
  }
  statement {
    actions = [
      "ec2:CreateSecurityGroup"]
    effect = "Allow"
    resources = [
      "*"]
  }

  #}
  #data "aws_iam_policy_document" "aws_loadbalancer_controller_continue_policy" {
  statement {
    actions = [
      "ec2:CreateTags"]
    effect = "Allow"
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"]
    condition {
      test = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateSecurityGroup"]
    }
    condition {
      test = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "false"]
    }

  }
  statement {
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"]
    effect = "Allow"
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"]
    condition {
      test = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "true"]
    }
    condition {
      test = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false"]
    }

  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup"]
    effect = "Allow"
    resources = [
      "*"]
    condition {
      test = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false"]

    }
  }
  statement {
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup"]
    effect = "Allow"
    resources = [
      "*"]
    condition {
      test = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "false"]
    }
  }
  statement {
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule"]
    effect = "Allow"
    resources = [
      "*"]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"]
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/*/*"]
    condition {
      test = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "true",
        "false"]
    }
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"]
    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener-rule/app/*/*/*"]
  }
  statement {
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup"]
    effect = "Allow"
    resources = [
      "*"]
    condition {
      test = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false"]
    }
  }
  statement {
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"]
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*"]
  }
  statement {
    actions = [
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule"]
    effect = "Allow"
    resources = [
      "*"]
  }
}

data "aws_iam_policy_document" "aws_loadbalancer_controller_assume_policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)[4]}"]
      type = "Federated"
    }
    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com"]
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)[4]}:aud"
    }
    condition {
      test = "StringEquals"
      values = [
        "system:serviceaccount:base:aws-load-balancer-controller"]
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)[4]}:sub"
    }
  }
}

resource "aws_iam_policy" "aws_loadbalancer_controller_policy" {
  name = "${local.prefix}-aws-eks-loadbalancer-policy"
  policy = data.aws_iam_policy_document.aws_loadbalancer_controller_policy.json

  tags = {
    Name = "${local.prefix}-eks-loadbalancer-policy"
    Client = var.client
    Environment = var.environment
  }
}

# Added role to support EBS CSI Driver for persistent volumes. https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi-migration-faq.html
data "aws_iam_policy_document" "aws-ebs-csi-driver-trust-policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)[4]}"]
      type = "Federated"
    }
    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com"]
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)[4]}:aud"
    }
    condition {
      test = "StringEquals"
      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"]
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)[4]}:sub"
    }
  }
}
