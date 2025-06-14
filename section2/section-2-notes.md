# AWS Identity and Access Management Services

# Overview
AWS provides several identity and access management services, each catering to different needs. Here’s a breakdown of three main services:

## 1. AWS Identity and Access Management (IAM)
- **Overview**: Core AWS solution for creating and managing permissions.
- **Pros**:
  - Granular control over permissions and access.
  - Supports both programmatic and console access.
  - Enables use of IAM roles for temporary access.
- **Cons**:
  - Can become complex at scale with many users and roles.
  - Requires careful planning to avoid permission misconfigurations.

## 2. AWS Identity Center (formerly AWS Single Sign-On)
- **Overview**: Manages access to multiple AWS accounts and business applications centrally.
- **Pros**:
  - Simplifies user management across multiple accounts.
  - Facilitates single sign-on to various services.
  - Can integrate with existing identity providers.
- **Cons**:
  - Less granular permissions control compared to IAM.
  - May not support all use cases with advanced permission configurations.

## 3. Amazon Cognito
- **Overview**: Authenticates users for web and mobile applications.
- **Pros**:
  - Great for user authentication without server-side code.
  - Supports social identity providers (e.g., Google, Facebook).
  - Scales automatically for millions of users.
- **Cons**:
  - More suited for end-user applications than managing AWS resource access.
  - Advanced features may require additional configuration.

## Summary
Your choice of service would depend on your requirements: fine-grained access control (IAM), centralized user management (Identity Center), or user authentication in applications (Cognito). Each service has its strengths and is best suited for different scenarios.

# Differences Between User Accounts, Developer Groups, and IAM Roles

## 1. User Accounts
- **Overview**: Represents individual AWS users or service accounts that can access AWS services.
- **Key Features**:
  - Can be assigned various permissions.
  - Access can be console-based, programmatic, or both.
  - Each user has unique credentials (username/password or access keys).

## 2. Developer Groups
- **Overview**: A collection of IAM users that typically share the same permissions and responsibilities.
- **Key Features**:
  - Simplifies management by allowing permissions to be applied at the group level rather than individually.
  - Ideal for organizing users by function (e.g., developers, admins).
  - Permissions granted to the group cascade down to all users in the group.

## 3. IAM Roles
- **Overview**: An IAM role is similar to a user account but is intended to be assumed by anyone (or any service) needing temporary access to specific AWS resources.
- **Key Features**:
  - Provides temporary security credentials to entities that assume the role.
  - Can be used for **cross-account access** or allowing AWS services to access resources.
  - Does not have long-term credentials (usernames and passwords); instead, it grants permissions dynamically.

### Example use cases
- Include EC2 instances needing access to S3 buckets or Lambda functions needing permissions to write logs.
- Don't need to create user accounts for every account )e.g. dev or production environments). You can create a role that can be assumed by users or services in those accounts.
- You can give IAM roles to 3rd party services or applications that need access to your AWS resources without sharing long-term credentials.

## Summary
In essence:
- User accounts are for individual users requiring access to AWS services.
- Developer groups simplify user management by grouping users with shared permissions.
- IAM roles provide flexible and temporary access, ideal for services or individuals needing limited-time permissions.

## AWS Identity Center
When using AWS Identity Center, you can manage user access across multiple AWS accounts and applications. It allows you to:
- Create user identities and assign them to groups e.g. developers, server administrators, users. 
- It allows you to manage multiple accounts at once.
- You can define **permission sets** that specify what users can do in each account. You can also assign temporary permissions to users.
- It is aware of all of the accounts in your AWS Organization, making it easier to manage access across accounts.

# Amazon Cognito
Amazon Cognito is primarily used for user authentication in web and mobile applications. It can use OAuth 2.0 and OpenID Connect protocols to authenticate users.

It allows you to create:
* User pool - a user directory that manages sign-up and sign-in functionality.
* Identity pool - a way to grant users access to AWS resources. It can be used to authenticate users from social identity providers (like Google, Facebook) or SAML-based identity providers.
It allows you to manager permissions (principle of least privilege) for different user groups and roles.

### Process Flow
client connects to Cognito User Pool
- User signs up or signs in.
- Cognito User Pool authenticates the user and returns a JSON Web Token (JWT).
- The client can then use this JWT to access AWS resources via the Identity Pool.
- The Identity Pool uses the JWT to grant temporary AWS credentials based on the user's group and role permissions.
- The client can then use these credentials to access AWS services like S3, DynamoDB, etc.

## Role Switch Operation
When using AWS Identity Center, users can switch roles to access different accounts or permission sets. This is done through the AWS Management Console or CLI, allowing users to assume different roles without needing separate credentials for each account.

Click on user > Switch Role > Enter the account ID and role name you want to switch to.

## Root User
When you create an AWS account, you have a root user that has full access to all AWS services and resources in the account. It is recommended to:
- **Avoid using the root user for everyday tasks**: Instead, create individual IAM users with specific permissions.
- **Avoid using CLI for the root user**

Root users are the only ones that can 
* Change account settings
* Restore IAM user permissiones
* Close an AWS account
* Activate IAM access to billing and cost management
* Configure an s3 bucket to use MFA
And multiple others

## Adding Users to Accounts
Create users
Assign users to groups (AWS managed groups or custom groups)
Assign permissions to groups (AWS managed policies or custom policies)

## IAM Roles
You can create IAM
You cac assign multiple roles/users to multiple groups and vice versa.

IAM policies are written in json. They contain:
* policy version:
* statement id: 
* statement:
  - statemend id (sid) - identifier for the statement
  - effect - what the policy does (allow or deny)
    - action what the policy allows or denies (e.g., s3:ListBucket) - this defines the service and the action.
    - resource - lists the resource that the policy applies to (e.g., arn:aws:s3:::my-bucket/*)
* condition - optional conditions that must be met for the policy to apply (e.g., IP address, time of day). For example you might want to restrict access to a resource only from a specific IP address or during a specific time period.

Wildcards (`*`) allow you to broaden the scope of a policy.

### ARN formats:
* arn:<partition>:<service>:<region>:<account-id>:<resource-type>/<resource-name>
* arn:<partition>:<service>:<region>:<account-id>:<resource-type>/<resource-name>/<resource-id>

paritions - different AWS regions
service - the AWS service (e.g., s3, ec2, iam)

### Example IAM Policy

Allow users to list and get objects from a specific s3 bucket.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-bucket"
    },
    {
      "Sid": "AllowS3GetObject",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```
Example allowing usrs to start and stop EC2 instances
NB resources are denied by default so we need to allow everything before explicitly denying something.

We can use variables in the policy to maker it more dynamic. For example, we can use `{aws:username}` to refer to the username of the user making the request. This allows us to create policies that are specific to each user.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEC2StartStop",
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "arn:aws:ec2:us-west-2:*:instance/*"
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Owner": "${aws:username}"
        }
      }
    }
  ]
}
```

# AWS Account Access with CLI
To access AWS resources we create an access key and secret access key locally.

## Create Access key
IAM > Users > Select User > Security Credentials > Create Access Key

```bash
# you can configure access keys for the different AWS profiles.
# if you exclude --profile then it will just use the default profile.
aws configure --profile <profile_name>
> AWS Access Key ID [None]: <your_access_key_id>
> AWS Secret Access Key [None]: <your_secret_access_key>
> Default region name [None]: <your_region>
```

## Create an IAM Role (for multiple entities unlike IAM users)

Example use case:
- Maggie is working in a dev environment and needs to access an S3 bucket in a prod environment (different account). 
- Instead of creating a user for Maggie, we can create a role that = Maggie can assume when she needs to access the S3 bucket.
- We can create an IAM role so that she can access the prod bucket
- We must also create a trust policy that allows Maggie to assume the role.
- Then she will perform an assume role operation to get temporary credentials that she can use to access the S3 bucket.

## Resource Based Policies
This policy has a principle element (in the json policy) that specifies the user or service that can access the resource. This is different from IAM policies, which are attached to users, groups, or roles.

You can also use a wildcard to allow access to the general public.

Maggie's story
We can create a resource-based policy on the S3 bucket that allows Maggie to access the bucket. This way, she doesn't need to assume a role, and we can control access to the bucket directly. This means she ddoesnt have to switch roles or use temporary credentials

GO to resource > Permissions > Bucket Policy
set the principle to the user or service that needs access to the resource.