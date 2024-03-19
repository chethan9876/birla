# Terraform Troubleshooting guide

## Issues

1. │ Error: Provider configuration not present
   │
   │ To work with module.core_apps.module.elasticsearch_kms_key.aws_kms_alias.kms_key_alias (orphan) its original provider configuration at module.core_apps.module.elasticsearch_kms_key.provider["registry.terraform.io/hashicorp/aws"] is required,
   │ but it has been removed. This occurs when a provider configuration is removed while objects created by that provider still exist in the state. Re-add the provider configuration to destroy
   │ module.core_apps.module.elasticsearch_kms_key.aws_kms_alias.kms_key_alias (orphan), after which you can remove the provider configuration again.
   ╵
If the modules are moved in the code, terraform throws the above issue. We can delete the objects from state and recreate the object. Or move the objects in state file.
eg,.
`terraform state mv 'module.core_apps.module.elasticsearch_kms_key' 'module.core_apps.module.elasticsearch_logs.module.elasticsearch_kms_key'
`terraform state mv 'module.core_apps.module.es_snapshot_s3_bucket' 'module.core_apps.module.elasticsearch_logs.module.es_snapshot_s3_bucket'

2. To import existing objects into terraform state, use import command.
eg.
`terraform import --var-file="vars-stg-ca-calgary.tfvars" module.core_apps.module.eks.aws_eks_node_group.cluster-node-group stg-calgary-eks:stg-ca-calgary-eks-cluster-node-group`

3. To remove an object from terraform state, use rm command
eg.,
`terraform state rm module.core_apps.module.eks.aws_eks_node_group.cluster-node-group  `