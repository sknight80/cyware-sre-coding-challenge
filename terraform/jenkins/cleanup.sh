#!/bin/bash

aws ecs update-service --cluster jenkins-cluster --service myflask --desired-count 0 --no-paginate
aws ecs describe-services --cluster jenkins-cluster --services myflask --no-paginate
aws ecs delete-service --cluster jenkins-cluster --service myflask --no-paginate

aws ecr batch-delete-image --repository-name my-app-repository --image-ids "$(aws ecr list-images --repository-name my-app-repository --query 'imageIds[*]' --output json)"

terraform destroy -auto-approve
