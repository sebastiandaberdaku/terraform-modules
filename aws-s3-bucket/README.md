# aws-s3-bucket

This Terraform module extends the well-known 
["terraform-aws-modules/s3-bucket/aws"](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) module by 
enforcing prefix-based naming convention and tagging.

Differently from the original module, this module will also merge and apply multiple bucket policy documents if 
provided.
