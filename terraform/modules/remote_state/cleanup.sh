#!/bin/bash

aws s3api delete-objects --bucket cyware-terraform-state-test --delete "$(aws s3api list-object-versions --bucket cyware-terraform-state-test --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

terraform destroy -auto-approve