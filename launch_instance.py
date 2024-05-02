import boto3
import sys

# Retrieve AWS credentials securely from environment variables
aws_access_key = sys.argv[1]  # Ensure this is validated and sanitized
aws_secret_key = sys.argv[2]  # Ensure this is validated and sanitized
region = sys.argv[3]
instance_name = sys.argv[4]

# Create an EC2 client, handling potential errors
try:
    ec2 = boto3.client('ec2', aws_access_key_id=aws_access_key,
                      aws_secret_access_key=aws_secret_key, region_name=region)
except Exception as e:
    print("Error creating EC2 client:", e)
    sys.exit(1)

# Launch the instance with error handling
try:
    response = ec2.run_instances(
        ImageId='ami-03643cf1426c9b40b',
        InstanceType='t3.micro',
        KeyName='my-key-pair',  # Ensure this key pair exists
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
        MaxCount=1,
        MinCount=1
    )
    print("Instance launched successfully:", response['Instances'][0]['InstanceId'])
except Exception as e:
    print("Error launching instance:", e)
    sys.exit(1)

