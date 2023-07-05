# Remote State Configuration

This folder contains Terraform configuration for setting up a remote state backend using Amazon S3 and DynamoDB.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) version 0.13 or newer
- [AWS CLI](https://aws.amazon.com/cli/) version 2.x
- An AWS account with necessary permissions for creating S3 buckets and DynamoDB tables
- A configured AWS CLI profile (use `aws configure` to set this up)

## Folder Structure

- `dynamodb.tf`: Contains the Terraform configuration for creating a DynamoDB table for state locking.
- `provider.tf`: Configures the AWS provider and required provider version.
- `s3.tf`: Contains the Terraform configuration for creating an S3 bucket for storing the remote state.
- `outputs.tf`: Contains output definitions for the created resources.

## Getting Started

1. Clone this repository:

    ```bash
    git clone https://github.com/your-repo/terraform-remote-state.git
    cd terraform-remote-state/remote_state
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Apply the Terraform plan to create the remote state resources:

    ```bash
    terraform apply
    ```

4. Take note of the output values, which include the S3 bucket name and DynamoDB table name.

## Cleanup

To clean up and destroy the remote state resources, run the following command:

```bash
terraform destroy
```

> **Note:** Make sure to have appropriate backups of your Terraform state files before destroying the remote state resources.

## Outputs

The following outputs are available:

- `bucket_name`: The name of the S3 bucket used for remote state storage.
- `dynamodb_table_name`: The name of the DynamoDB table used for state locking.

These output values can be referenced in other Terraform configurations by using the `terraform_remote_state` data source.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
