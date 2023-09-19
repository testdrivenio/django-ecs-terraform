import boto3
import click

def get_current_task_definition(client, cluster, service):
    response = client.describe_services(cluster=cluster, services=[service])
    current_task_arn = response["services"][0]["taskDefinition"]
    return client.describe_task_definition(taskDefinition=current_task_arn)

@click.command()
@click.option("--cluster", help="Name of the ECS cluster", required=True)
@click.option("--service", help="Name of the ECS service", required=True)
def deploy(cluster, service):
    client = boto3.client("ecs")
    container_definitions = []
    response = get_current_task_definition(client, cluster, service)
    for container_definition in response["taskDefinition"]["containerDefinitions"]:
        new_def = container_definition.copy()
        container_definitions.append(new_def)

    response = client.register_task_definition(
        family=response["taskDefinition"]["family"],
        volumes=response["taskDefinition"]["volumes"],
        containerDefinitions=[container_definition],
        cpu='256',  # Modify based on your needs
        memory='512',  # Modify based on your needs
        networkMode='awsvpc',
        requiresCompatibilities=['FARGATE'],
        executionRoleArn='ecs_task_execution_role_prod',
        taskRoleArn='ecs_task_execution_role_prod'
    )
    new_task_arn = response["taskDefinition"]["taskDefinitionArn"]
    client.update_service(
        cluster=cluster, service=service, taskDefinition=new_task_arn,
    )

if __name__ == "__main__":
    deploy()