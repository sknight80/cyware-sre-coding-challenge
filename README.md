# Jenkins CI/CD Pipeline with Terraform

This project sets up a Jenkins CI/CD pipeline using Terraform. The infrastructure includes a Jenkins server running on an AWS EC2 instance, an Elastic Container Registry (ECR), an Elastic Container Service (ECS) cluster, and an Application Load Balancer (ALB).

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) version 0.13 or newer
- [AWS CLI](https://aws.amazon.com/cli/) version 2.x
- An AWS account with necessary permissions for creating IAM roles, EC2 instances, ECR, ECS, ALB, and VPC
- A configured AWS CLI profile (use `aws configure` to set this up)
- SSH key pair for accessing the EC2 instance / GitHub (defaultl used by `<repo>/jenkins_example.pub`) Check the terraform/jenkins/variables.tf file for the default value.

## Getting Started

1. Clone this repository:

    ```bash
    git clone https://github.com/sknight80/cyware-sre-coding-challenge.git
    cd cyware-sre-coding-challenge/terraform/modules/remote_state
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Run the Terraform plan to see the infrastructure changes:

    ```bash
    terraform plan
    ```

4. Apply the Terraform plan to create the infrastructure:

    ```bash
    terraform apply
    ```

5. Naviage to the jenkins directory:

    ```bash
    cd ../jenkins
    ```

6. Initialize Terraform:

    ```bash
    terraform init
    ```

7. Run the Terraform plan to see the infrastructure changes:

    ```bash
    terraform plan
    ```

8. Apply the Terraform plan to create the infrastructure:

    ```bash
    terraform apply
    ```

9. Access Jenkins:

    After Terraform applies the configuration, the Jenkins server will be accessible at the public IP or DNS of the EC2 instance. Open a web browser and navigate to `http://<EC2-Instance-Public-IP>:8080` to access the Jenkins web interface. (or using the application load balancer URL without the port 8080, this is the **preferred method**)


10. Configure Jenkins:

    Initial configuration is done by user_data.sh script.  This script will install the necessary plugins and configure the Jenkins server.  The script will also create a new admin user with the username `admin` and password `admin`.  You can use these credentials to log in to the Jenkins web interface.

11. Configure GitHub Webhook:

    To trigger the pipeline automatically on code changes, configure the GitHub webhook for your repository. Follow these steps:
    
    - Go to your GitHub repository and navigate to `Settings` > `Webhooks`.
    - Click on `Add webhook`.
    - Enter the following details:
      - Payload URL: `http://<ALB-URL>:8080/github-webhook/` (or the URL of the Jenkins server)
      - Content type: `application/json`
      - Select the events you want to trigger the webhook (e.g., `Push` for any code changes).
    - Save the webhook configuration.

## Structure

- `alb.tf`: Contains the configurations for the Application Load Balancer (ALB).
- `ecr.tf`: Contains the configurations for the Elastic Container Registry (ECR).
- `ecs.tf`: Contains the configurations for the ECS cluster.
- `iam.tf`: Contains the configurations for the IAM roles and policies.
- `internet_gateway.tf`: Contains the configurations for the internet gateway.
- `jenkins.tf`: Contains the configurations for the Jenkins server.
- `main.tf`: Contains the main configuration for the project.
- `outputs.tf`: Contains the outputs for the Terraform configuration.
- `provider.tf`: Configures the AWS provider.
- `routing_table.tf`: Contains the configurations for the routing table.
- `user_data.sh`: Contains the user data script that sets up the EC2 instance with Jenkins, Docker, AWS CLI, and configures the Jenkins instance via Jenkins Configuration as Code (JCasC).
- `vpc.tf`: Contains the configurations for the VPC.
- `variables.tf`: Contains the variables used in the configurations.


## Configuring GitHub and Jenkins Integration

### SSH Key Configuration

If you want global access for your SSH key, follow these steps:

1. Generate SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
    ```

2. Copy the public key:

    ```bash
    cat ~/.ssh/id_rsa.pub
    ```

3. Go to your GitHub account settings and navigate to "SSH and GPG keys".

4. Click on "New SSH key" and paste the copied public key into the "Key" field.

5. Save the SSH key.

### Deploy Key Configuration (Limited Access)

If you want to limit the access of your SSH key to a given repository, follow these steps:

1. Generate SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
    ```

2. Copy the public key:

    ```bash
    cat ~/.ssh/id_rsa.pub
    ```

3. Go to your GitHub repository settings and navigate to "Deploy keys".

4. Click on "Add deploy key" and paste the copied public key into the "Key" field.

5. Save the deploy key.

By configuring the SSH key globally or as a deploy key, Jenkins will have the necessary access to the repository to trigger pipeline jobs.


## Cleaning Up

To destroy the environment and clean up all the resources created by Terraform, run the following command from the `terraform/jenkins` directory:

```bash
./cleanup.sh
```
This will run the cleanup script and remove all the provisioned resources.


## Improvements

- Implement autoscaling for the EC2 instances in the ECS cluster.
- Use Terraform modules for reusability and to manage the infrastructure as code.
- Store sensitive data, such as AWS access keys or secrets, securely using AWS Secrets Manager or Parameter Store.
- Update the pipeline to use Terraform to deploy the Flask Docker image to ECS.
- Add more detailed instructions and examples for using the Jenkins CI/CD pipeline with different project types.
- Fix auto-triggering of the pipeline on code changes.
- Remove public IPv4 assignment from the EC2 instance and use a private subnet instead.



## Warnings

- Ensure you have the necessary permissions in your AWS account before running this configuration.
- Always run `terraform plan` before `terraform apply` to understand the changes Terraform will perform.
- This configuration does not include cleanup. Use `terraform apply -destroy` to delete the resources when you're done using them (see more information in Warning: ECS Task and Terraform Destroy).
- Remember to not upload any sensitive data like AWS Access Keys or Secret Keys to your version control system.


## Warning: ECS Task and Terraform Destroy

If you have an ECS task running on the ECS cluster created by Terraform, it is important to stop the task before running `terraform destroy`. Terraform cannot destroy the ECS cluster while tasks are still running on it.

To gracefully handle this situation, follow these steps:

1. **Stop the ECS task**: Use the AWS Management Console, AWS CLI, or SDK to stop the ECS task associated with the running container. This will terminate the running task and stop the container.

2. **Wait for the ECS task to stop**: Monitor the ECS task status to ensure that it has stopped successfully. You can use the AWS Management Console, AWS CLI, or SDK to check the task status.

3. **Run `terraform destroy`**: Once the ECS task has stopped, you can run `terraform destroy` to destroy the ECS cluster and any associated resources.

By following these steps, you ensure that the ECS task is gracefully stopped before running `terraform destroy`, allowing Terraform to clean up all resources created by the ECS cluster.

> **Note:** Remember to exercise caution while using `terraform destroy` as it permanently deletes resources. Ensure that you have backups or any necessary precautions in place before proceeding.


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
