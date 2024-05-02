import boto3
import sys

# Retrieve AWS credentials and region from command-line arguments
try:
    aws_access_key = sys.argv[1]
    aws_secret_key = sys.argv[2]
    region = sys.argv[3]
except IndexError:
    print("Usage: python launch_instance.py <aws_access_key> <aws_secret_key> <region>")
    sys.exit(1)

# Specify instance details
image_id = 'ami-03643cf1426c9b40b'
instance_type = 't3.micro'
key_name = 'team34'  # Ensure this key pair exists in your AWS account
instance_name = 'xerox01'

# Create an EC2 client
try:
    ec2 = boto3.client('ec2', aws_access_key_id=aws_access_key, aws_secret_access_key=aws_secret_key, region_name=region)
except Exception as e:
    print("Error creating EC2 client:", e)
    sys.exit(1)

# Launch the instance, providing MaxCount and MinCount
try:
    response = ec2.run_instances(
        ImageId=image_id,
        InstanceType=instance_type,
        KeyName=key_name,
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': instance_name
                    }
                ]
            }
        ],
        MaxCount=1,  # Launch a maximum of 1 instance
        MinCount=1   # Launch a minimum of 1 instance
    )
    print("Instance launched successfully:", response['Instances'][0]['InstanceId'])
except Exception as e:
    print("Error launching instance:", e)
    sys.exit(1)

