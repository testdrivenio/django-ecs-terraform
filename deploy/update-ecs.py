import subprocess

import boto3
import click


def get_terraform_output(output_name):
    try:
        return subprocess.check_output(
            ["terraform", "output", "-state=../terraform/terraform.tfstate", output_name],
            text=True
        ).strip()
    except Exception as e:
        print(f"Error fetching Terraform output {output_name}: {e}")
        return None

def get_current_task_definition(client, cluster, service):
    response = client.describe_services(cluster=cluster, services=[service])
    current_task_arn = response["services"][0]["taskDefinition"]
    return client.describe_task_definition(taskDefinition=current_task_arn)

def run_collectstatic_task(client, cluster, task_definition_name):
    print("Running collectstatic task...")

    response = client.run_task(
        cluster=cluster,
        taskDefinition=task_definition_name,
        launchType="FARGATE",
        networkConfiguration=network_configuration,  # Add the network configuration here
    )

    if response.get("tasks"):
        print(f"collectstatic task started with task ARN: {response['tasks'][0]['taskArn']}")
    else:
        print("Failed to start collectstatic task.")
        if response.get("failures"):
            for failure in response["failures"]:
                print(f"Reason: {failure['reason']}")

subnets = [s.strip(' "\n[]') for s in get_terraform_output("subnets").split(",") if "subnet" in s]
security_group = get_terraform_output("security_group").strip(' "\n')
network_configuration = {
    "awsvpcConfiguration": {
        "subnets": subnets,
        "securityGroups": [security_group],
        "assignPublicIp": "ENABLED"
    }
}

@click.command()
@click.option("--cluster", help="Name of the ECS cluster", required=True)
@click.option("--service", help="Name of the ECS service", required=True)
@click.option("--image", help="Docker image URL for the updated application", required=True)
@click.option("--container-name", help="Name of the container to update", required=True)
@click.option("--collectstatic-task", help="Name of the collectstatic task definition", default="django-collectstatic-task")
def deploy(cluster, service, image, container_name, collectstatic_task):
    client = boto3.client("ecs")

    # Run the collectstatic task
    run_collectstatic_task(client, cluster, collectstatic_task)

    # Fetch the current task definition
    print("Fetching current task definition...")
    response = get_current_task_definition(client, cluster, service)

    # Iterate over container definitions and update the image for the matching container
    container_definitions = response["taskDefinition"]["containerDefinitions"]
    for container in container_definitions:
        if container["name"] == container_name:
            container["image"] = image
            print(f"Updated {container_name} image to: {image}")

    # Register a new task definition
    print("Registering new task definition...")
    response = client.register_task_definition(
        family=response["taskDefinition"]["family"],
        volumes=response["taskDefinition"]["volumes"],
        containerDefinitions=container_definitions,
        cpu="256",  # Modify based on your needs
        memory="512",  # Modify based on your needs
        networkMode="awsvpc",
        requiresCompatibilities=["FARGATE"],
        executionRoleArn="ecs_task_execution_role_prod",
        taskRoleArn="ecs_task_execution_role_prod"
    )
    new_task_arn = response["taskDefinition"]["taskDefinitionArn"]
    print(f"New task definition ARN: {new_task_arn}")

    # Update the service with the new task definition
    print("Updating ECS service with new task definition...")
    client.update_service(
        cluster=cluster, service=service, taskDefinition=new_task_arn,
    )
    print("Service updated!")


if __name__ == "__main__":
    deploy()
