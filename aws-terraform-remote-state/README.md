# AWS Terraform Remote State base module

This Terraform module contains the base resources required to set-up the remote state on AWS.

These resources include:
1. The Terraform remote state S3 storage bucket
2. The Terraform remote state DynamoDB Table lock
3. The Terraform Admin IAM Role

This module should be used in a dedicated repository, separate from the main infrastructure repo, only used once for 
bootstrapping. The state files should be saved separtely for each AWS environment and can be added to this repository.
Please notice that there is no concurrency control or locking mechanism for these templates, so please be very careful when applying them.
