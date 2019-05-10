# S3toAZ

A simple S3 to AZ Storage copier in Python so you can create a scheduled function in Azure to copy files.

You need an AWS S3 bucket with a Bucket Policy for an IAM user like this:

``` json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Minimal Permissions for getting an object",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::[id]:user/[username]"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::[bucketname]/*"
        }
    ]
}
```

For testing purposes you can use the command line, but it is recommended to use environment variables when you deploy it to an Azure Function.

**AWS_SOURCE**
**AWS_SECRET_ID**
**AWS_SECRET_ACCESS_KEY**
**AZ_DESTINATION**
**AZ_DESTINATION_SAS**