#import boto3
import argparse
import os

def getArgs():
    parser= argparse.ArgumentParser("Copy S3 to Azure Storage")
    parser.add_argument('-s','--source', type=str,help="The S3 bucket: https://[region like s3-eu-west-1].amazonaws.com/[bucketname]/[foldername]/[filename], can also be set by the [AWS_SOURCE] environment variable")
    parser.add_argument('--source_secret_id',type=str,help="The S3 SECRET ID, can also be set by the [AWS_SECRET_ID] environment variable")
    parser.add_argument('--source_secret_key',type=str,help="The S3 SECRET ACCESS KEY, can also be set by the [AWS_SECRET_ID] environment variable")
    parser.add_argument('-d','--destination',type=str, help="The Azure Storage account, can also be set by the [AZ_DESTINATION] environment variable")
    parser.add_argument('--destination_SAS',type=str, help="The Azure Storage SAS Token, can also be set by the [AZ_DESTINATION_SAS] environment variable")
    return parser.parse_args()

def getEnv():
    class Object(object):
        pass

    env_data=Object()
    env_data.source=os.environ.get("AWS_SOURCE")
    env_data.source_secret_id=os.environ.get('AWS_SECRET_ID')
    env_data.source_secret_key=os.environ.get('AWS_SECRET_ACCESS_KEY')
    env_data.destination=os.environ.get("AZ_DESTINATION")
    env_data.destination_SAS=os.environ.get("AZ_DESTINATION_SAS")
    return env_data


#def copy(name):
#    s3 = boto3.resource('s3')
    #bucket=s3.Bucket

args= getArgs()
env= getEnv()


print(args.source)
print(env.source)