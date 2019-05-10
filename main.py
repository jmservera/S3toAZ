import boto3
import argparse
import os
import logging

def getArgs():
    """Gets the needed values from the command line arguments"""
    parser= argparse.ArgumentParser("Copy S3 to Azure Storage")
    parser.add_argument('-s','--source', type=str,help="The S3 bucket: https://[region like s3-eu-west-1].amazonaws.com/[bucketname]/[foldername]/[filename], can also be set by the [AWS_SOURCE] environment variable")
    parser.add_argument('--source_secret_id',type=str,help="The S3 SECRET ID, can also be set by the [AWS_SECRET_ID] environment variable")
    parser.add_argument('--source_secret_key',type=str,help="The S3 SECRET ACCESS KEY, can also be set by the [AWS_SECRET_ID] environment variable")
    parser.add_argument('-d','--destination',type=str, help="The Azure Storage account, can also be set by the [AZ_DESTINATION] environment variable")
    parser.add_argument('--destination_SAS',type=str, help="The Azure Storage SAS Token, can also be set by the [AZ_DESTINATION_SAS] environment variable")
    return parser.parse_args()

def getEnv():
    """Gets needed values from OS Environment"""
    class Object(object):
        pass

    env_data=Object()
    env_data.source=os.environ.get("AWS_SOURCE")
    env_data.source_secret_id=os.environ.get('AWS_SECRET_ID')
    env_data.source_secret_key=os.environ.get('AWS_SECRET_ACCESS_KEY')
    env_data.destination=os.environ.get("AZ_DESTINATION")
    env_data.destination_SAS=os.environ.get("AZ_DESTINATION_SAS")
    return env_data

def merge(source,dest):
    """Merge two objects, it will update only the empty (None) attributes in [dest] from [source]
    """
    elements=vars(source)
    for element in elements:
        value=elements[element]
        if getattr(dest,element)==None:
            setattr(dest,element,value)
    
    elements=vars(dest)

def checkValues(obj):
    """Checks that all the needed values are filled and creates a warning if not"""
    elements=vars(obj)
    for element in elements:
        if elements[element]==None:
            logging.warning(element+" does not have a value.")

def initArgs():
    args= getArgs()
    env= getEnv()
    merge(env,args)
    checkValues(args)
    return args

def copy(name, args):
    s3 = boto3.client("s3", aws_access_key_id=args.source_secret_id, aws_secret_access_key=args.source_secret_key)
    #TODO: download to a stream
    #with open('[filename]', 'wb') as f:
    #    s3.download_fileobj('[bucket]', '[object]', f)

args=initArgs()

copy("test",args)

print(args.source)
print(args.source_secret_id)