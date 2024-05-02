#!/bin/bash

sudo yum update -y

sudo yum install httpd php -y
cat << EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login Page</title>
  <style>
    /* Style for buttons and forms */
    /* Add your own styles here */
    .button-container {
      text-align: center;
      margin: 50px auto;
    }
    /* Rest of the styles */
  </style>
</head>
<body>
  <div id="startPage">
    <button onclick="showCenterInfo()">Centers Login</button>
    <button onclick="showCustomerUpload()">Customer</button>
  </div>

  <div id="centerInfo" style="display: none;">
    <div class="button-container">
      <button onclick="showPrinters()">Show Printers</button>
      <button onclick="showJobs()">Show Jobs</button>
    </div>

    <div id="printersTable" style="display: none;">
      <h2>Printers Table</h2>
      <table id="printers">
        <!-- Printer table will be displayed here -->
      </table>
    </div>

    <div id="jobsTable" style="display: none;">
      <h2>Printer Jobs</h2>
      <table id="jobs">
        <!-- Job table will be displayed here -->
      </table>
    </div>
  </div>
<div id="customerUpload" style="display: none;">
    <form enctype="multipart/form-data" action="/upload.php" method="post">
      <input type="file" name="fileUpload" id="fileUpload">
      <input type="submit" value="Upload File" name="submit">
    </form>
  </div>
  <script>
    // Simulated printer data and jobs (replace this with your actual data retrieval method)
    const printersData = [
      { id: 1, name: 'Printer 1', status: 'Online' },
      { id: 2, name: 'Printer 2', status: 'Offline' },
      // Add more printer data as needed
    ];

    const jobsData = [
      { id: 1, user: 'John Doe', pages: 5 },
      { id: 2, user: 'Jane Smith', pages: 3 },
      // Add more job data as needed
    ];

    function showCenterInfo() {
      document.getElementById("startPage").style.display = "none";
      document.getElementById("centerInfo").style.display = "block";
    }

    function showPrinters() {
      document.getElementById('printersTable').style.display = 'block';
      document.getElementById('jobsTable').style.display = 'none';

      const printersTable = document.getElementById('printers');
      renderTable(printersData, printersTable, ['ID', 'Name', 'Status']);
    }

    function showJobs() {
      document.getElementById('jobsTable').style.display = 'block';
      document.getElementById('printersTable').style.display = 'none';

      const jobsTable = document.getElementById('jobs');
      renderTable(jobsData, jobsTable, ['ID', 'User', 'Pages']);
    }

    function renderTable(data, tableElement, headers) {
      // Clear existing table data
      while (tableElement.firstChild) {
        tableElement.removeChild(tableElement.firstChild);
      }

      // Create table headers
      const headerRow = document.createElement('tr');
      headers.forEach(headerText => {
        const th = document.createElement('th');
        th.textContent = headerText;
        headerRow.appendChild(th);
      });
      tableElement.appendChild(headerRow);

      // Create table rows with data
      data.forEach(item => {
        const row = document.createElement('tr');
        Object.values(item).forEach(value => {
          const cell = document.createElement('td');
          cell.textContent = value;
          row.appendChild(cell);
        });
        tableElement.appendChild(row);
      });
    }
  function showCustomerUpload() {
      document.getElementById("startPage").style.display = "none";
      document.getElementById("customerUpload").style.display = "block";
    }
  </script>
</body>
</html>


EOF
cat << EOF > /var/www/html/customer_uploads/upload.php
<?php
$targetDir = "/var/www/html/customer_uploads/";
$targetFile = $targetDir . basename($_FILES["fileUpload"]["name"]);
$uploadOk = 1;
$imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));

// Check if file already exists
if (file_exists($targetFile)) {
    echo "Sorry, file already exists.";
    $uploadOk = 0;
}

// Check file size (you can adjust this as needed)
if ($_FILES["fileUpload"]["size"] > 500000) {
    echo "Sorry, your file is too large.";
    $uploadOk = 0;
}

// Allow only certain file formats (you can adjust this as needed)
if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
    && $imageFileType != "gif" && $imageFileType != "pdf") {
    echo "Sorry, only JPG, JPEG, PNG, GIF, and PDF files are allowed.";
    $uploadOk = 0;
}

// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    echo "Sorry, your file was not uploaded.";
} else {
    if (move_uploaded_file($_FILES["fileUpload"]["tmp_name"], $targetFile)) {
        echo "The file " . basename($_FILES["fileUpload"]["name"]) . " has been uploaded.";
    } else {
        echo "Sorry, there was an error uploading your file.";
    }
}
?>
EOF
sudo systemctl enable httpd

sudo systemctl start httpd
sudo dnf update -y
sudo dnf install git -y
sudo dnf update -y
sudo dnf install java-17-amazon-corretto -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
