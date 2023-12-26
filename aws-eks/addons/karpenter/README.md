# aws-eks/addons/karpenter

This Terraform module extends the well-known 
["terraform-aws-modules/eks/aws//modules/karpenter"](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v19.21.0/modules/karpenter) 
module by enforcing prefix-based naming convention and tagging.

This module also installs Karpenter on the target EKS cluster using its official Helm Chart. Karpenter should not run on 
nodes managed by Karpenter itself. Also, to prevent disruptions, it is advisable to avoid running workloads on the nodes
that run Karpenter. The EKS cluster should have one node group of few small nodes dedicated to running Karpenter. 

For these reasons, Karpenter must run on nodes that:
1. do not have labels with key `karpenter.sh/nodepool`,
2. have a specific value for the label `eks.amazonaws.com/nodegroup` which must be provided as an input to this module,
3. have the taint `dedicated=Karpenter:NoSchedule`.
