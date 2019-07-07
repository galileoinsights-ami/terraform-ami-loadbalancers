#!/bin/bash

source setup-$ENV.sh

rm -rf .terraform

terraform init \
	-backend=true \
	-backend-config="bucket="$TF_VAR_backend_s3_bucket_name \
	-backend-config="region="$AWS_DEFAULT_REGION \
	-backend-config="access_key="$AWS_ACCESS_KEY_ID \
	-backend-config="secret_key="$AWS_SECRET_ACCESS_KEY

terraform destroy -var-file=env/$ENV-$AWS_DEFAULT_REGION.tfvars