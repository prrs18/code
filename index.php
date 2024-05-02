<?php
// Include the AWS SDK for PHP
require 'vendor/autoload.php';

use Aws\Ec2\Ec2Client;

// Retrieve AWS credentials from environment variables
$aws_access_key = 'AKIATEXQDTAHPKK2GMSL';
$aws_secret_key = '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';
$region = 'eu-north-1';

if (!$aws_access_key || !$aws_secret_key || !$region) {
  echo "Missing AWS credentials or region in environment variables.";
  exit;
}

// Create an EC2 client
$ec2 = new Ec2Client([
  'region' => $region,
  'version' => 'latest',
  'credentials' => [
    'key' => $aws_access_key,
    'secret' => $aws_secret_key
  ]
]);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  // Process form submission
  $instance_name = $_POST['instance_name'];

  try {
    // Read the Bash script contents
    $script_contents = file_get_contents('./deploy_httpd.sh');
    $encoded_script = base64_encode($script_contents);

    // Launch the EC2 instance with User Data
    $response = $ec2->runInstances([
      'ImageId' => 'ami-03643cf1426c9b40b', // Replace with your desired AMI
      'InstanceType' => 't3.micro',
      'KeyName' => 'team34', // Ensure this key pair exists
      'TagSpecifications' => [
        [
          'ResourceType' => 'instance',
          'Tags' => [
            [
              'Key' => 'Name',
              'Value' => $instance_name
            ]
          ]
        ]
      ],
      'MaxCount' => 1,
      'MinCount' => 1,
      'UserData' => $encoded_script // Pass the encoded script as User Data
    ]);

   $instanceId = $response['Instances'][0]['InstanceId'];
    echo "Instance launched successfully: " . $instanceId;

    // Wait for the instance to be running
    $ec2->waitUntil('InstanceRunning', [
        'InstanceIds' => [$instanceId],
    ]);

    // Describe the instance to get its IP address
    $result = $ec2->describeInstances([
        'InstanceIds' => [$instanceId],
    ]);
    $ipAddress = $result['Reservations'][0]['Instances'][0]['PublicIpAddress'];
   echo '<br>'; echo "Instance IP address: " . $ipAddress;
  } catch (Exception $e) {
    echo "Error launching instance or running deploy script: " . $e->getMessage();
  }
} else {
?>
<form method="post">
  <label for="instance_name">Enter instance name:</label>
  <input type="text" id="instance_name" name="instance_name">
  <button type="submit">Launch Instance</button>
</form>
<?php
}
?>

