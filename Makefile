TF=terraform

.PHONY: init plan apply destroy kubeconfig fmt

init:
	$(TF) init

plan:
	$(TF) plan -out=tfplan

apply:
	$(TF) apply tfplan

destroy:
	$(TF) destroy -auto-approve

kubeconfig:
	aws eks update-kubeconfig --name $(shell $(TF) output -raw cluster_id) --region $(shell $(TF) output -raw aws_region 2>/dev/null || echo ${AWS_REGION})

fmt:
	$(TF) fmt -recursive
