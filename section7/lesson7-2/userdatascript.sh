#!/bin/bash
# Update system and install Apache
sudo dnf update -y
sudo dnf install -y httpd

# Enable and start Apache service
sudo systemctl enable httpd
sudo systemctl start httpd

# Add ec2-user to apache group
sudo usermod -a -G apache ec2-user

# Set proper permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 775 /var/www/html

# Allow ec2-user to write to /var/www/html
sudo chown -R ec2-user:apache /var/www/html
sudo chmod -R g+w /var/www/html

# Restart Apache to apply changes
sudo systemctl restart httpd

# Sync website files from S3 bucket
aws s3 sync s3://[YOUR_S3_BUCKET_NAME] /var/www/html --delete
