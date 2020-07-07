# CloudTrail

AWS CloudTrail is a service that enables governance, compliance, operational auditing, and risk auditing of your AWS account. With CloudTrail, you can log, continuously monitor, and retain account activity related to actions across your AWS infrastructure. CloudTrail provides event history of your AWS account activity, including actions taken through the AWS Management Console, AWS SDKs, command line tools, and other AWS services.

CloudTrail is very important in the security realm, because it records every API call executed on our resources. We can also create trails that allow us to store logs longer than 90 days, and use them to trigger automation events.

PLease Refer : https://aws.amazon.com/cloudtrail/


## 1.Create s3 bucket to store logs
    a. Go to s3 
    b. create s3 bucket with name and everthing else is default

## 2.create Trails
    a. Go to CloudTrail
    b. select Trail on the left bar
    c. click on Create Trail
    d. Give name , Under storage location select S3 bucket you created before
    e. select sns nortification if you want to send nortification on each logs stored into bucekt.

## 3.Test CloudTrail logs
    a. Go to eks service
    b. click on any of the eks option
    c. come back to event history and ccheck for eks logs
    d. come to S3 ducket and check for logs
    
    
