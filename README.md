# Deploying Django to AWS ECS with Terraform

Sets up the following AWS infrastructure:

- Networking:
    - VPC
    - Public and private subnets
    - Routing tables
    - Internet Gateway
    - Key Pairs
- Security Groups
- Load Balancers, Listeners, and Target Groups
- IAM Roles and Policies
- ECS:
    - Task Definition (with multiple containers)
    - Cluster
    - Service
- Auto scaling config
- RDS
- Health Checks and Logs

## Want to learn how to build this?

Check out the [tutorial](https://testdriven.io/blog/deploying-django-to-ecs-with-terraform/).

## Want to use this project?

1. Install Terraform

1. Sign up for an AWS account

1. Create two ECR repositories, `django-app` and `nginx`.

1. Fork/Clone

1. Build the Django and Nginx Docker images and push them up to ECR:

    ```sh
    $ cd app
    $ docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/django-app:latest .
    $ docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/django-app:latest
    $ cd ..

    $ cd nginx
    $ docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/nginx:latest .
    $ docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/nginx:latest
    $ cd ..
    ```

1. Update the variables in *terraform/variables.tf*.

1. Set the following environment variables, init Terraform, create the infrastructure:

    ```sh
    $ cd terraform
    $ export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
    $ export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"

    $ terraform init
    $ terraform apply
    $ cd ..
    ```

1. Terraform will output an ALB domain. Create a CNAME record for this domain
   for the value in the `allowed_hosts` variable.

1. To apply the migrations, run the following command, making sure to replace `YOUR_SUBNET_1`, `YOUR_SUBNET_2`, and `YOUR_SECURITY_GROUP` with the values that were outputted to your terminal from the `terraform apply` command:

    ```sh
    $ aws ecs run-task \
        --cluster production-cluster \
        --task-definition django-migration-task \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[YOUR_SUBNET_1, YOUR_SUBNET_2],securityGroups=[YOUR_SECURITY_GROUP],assignPublicIp=ENABLED}"
    ```

1. Now you can open `https://your.domain.com/admin`. Note that `http://` won't work.

1. To collect the static files, navigate to the "deploy" folder, create and activate a Python virtual environment, install the requirements, and then run the following command, making sure to replace `<AWS_ACCOUNT_ID>` with your AWS account ID:

    ```sh
    (env)$ python update-ecs.py \
            --cluster=production-cluster \
            --service=production-service \
            --image="<AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/django-app:latest" \
            --container-name django-app
    ```

    You can use the same command to bump the Task Definition and update the Service.
