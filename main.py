import boto3
import argparse
import os
import logging
from azure.storage.blob import BlockBlobService,BlobBlock
import platform
import datetime
import uuid

def __getArgs():
    """Gets the needed values from the command line arguments"""
    parser= argparse.ArgumentParser("Copy S3 to Azure Storage")
    parser.add_argument('--source_bucket', type=str,help="The S3 bucket as in [BucketName]: https://[region like s3-eu-west-1].amazonaws.com/[bucketname]/[foldername]/[filename], can also be set by the [AWS_SOURCE_BUCKET] environment variable")
    parser.add_argument('--source_file', type=str,help="The S3 bucket as in [foldername]/[filename]: https://[region like s3-eu-west-1].amazonaws.com/[bucketname]/[foldername]/[filename], can also be set by the [AWS_SOURCE_FILE] environment variable")
    parser.add_argument('--source_secret_id',type=str,help="The S3 SECRET ID, can also be set by the [AWS_SECRET_ID] environment variable")
    parser.add_argument('--source_secret_key',type=str,help="The S3 SECRET ACCESS KEY, can also be set by the [AWS_SECRET_ID] environment variable")
    parser.add_argument('--destination_account',type=str, help="The Azure Storage account, can also be set by the [AZ_DESTINATION] environment variable")
    parser.add_argument('--destination_SAS',type=str, help="The Azure Storage SAS Token, can also be set by the [AZ_DESTINATION_SAS] environment variable")
    parser.add_argument('--destination_container',type=str, help="The Azure Storage blob container, can also be set by the [AZ_DESTINATION_CONTAINER] environment variable")
    parser.add_argument('--destination_file',type=str, help="The path to the destination file, can also be set by the [AZ_DESTINATION_FILE] environment variable")
    return parser.parse_args()

def __getEnv():
    """Gets needed values from OS Environment"""
    class Object(object):
        pass

    env_data=Object()
    env_data.source_bucket=os.environ.get("AWS_SOURCE_BUCKET")
    env_data.source_file=os.environ.get("AWS_SOURCE_FILE")
    env_data.source_secret_id=os.environ.get('AWS_SECRET_ID')
    env_data.source_secret_key=os.environ.get('AWS_SECRET_ACCESS_KEY')
    env_data.destination_account=os.environ.get("AZ_DESTINATION_ACCOUNT")
    env_data.destination_SAS=os.environ.get("AZ_DESTINATION_SAS")
    env_data.destination_container=os.environ.get("AZ_DESTINATION_CONTAINER")
    env_data.destination_file=os.environ.get("AZ_DESTINATION_FILE")
    
    return env_data

def __merge(source,dest):
    """Merge two objects, it will update only the empty (None) attributes in [dest] from [source]
    """
    elements=vars(source)
    for element in elements:
        value=elements[element]
        if getattr(dest,element)==None:
            setattr(dest,element,value)
    
    elements=vars(dest)

def __checkValues(obj):
    """Checks that all the needed values are filled and creates a warning if not"""
    elements=vars(obj)
    allValues=True
    for element in elements:
        if elements[element]==None:
            allValues=False
            logging.warning(element+" does not have a value.")
    #if all needed values are not supplied exit
    return allValues

def __initArgs():
    args= __getArgs()
    env= __getEnv()
    __merge(env,args)
    __checkValues(args)
    return args

def __copy(args):
    s3cli = boto3.resource("s3", aws_access_key_id=args.source_secret_id, aws_secret_access_key=args.source_secret_key)
    azblob= BlockBlobService(args.destination_account, args.destination_SAS)

    s3object=s3cli.Object(args.source_bucket, args.source_file)
    print("Opening S3 object {0}/{1}".format(args.source_bucket, args.source_file))
    chunk=s3object.get(PartNumber=1)
    nchunks=chunk['PartsCount']
    blocks=[]

    for x in range(1,nchunks+1):
        chunk=s3object.get(PartNumber=x)
        print("Reading part {0}/{1}".format(x,nchunks))
        part=chunk['Body'].read()
        print("Writing part {0}/{1}. Size: {2} bytes".format(x,nchunks,len(part)))
        blockid=uuid.uuid4()
        azblob.put_block(args.destination_container,args.destination_file,part,blockid)
        blocks.append(BlobBlock(id=blockid))

    print("Committing file {0}/{1}".format(args.destination_container, args.destination_file))
    azblob.put_block_list(args.destination_container,args.destination_file,blocks)
    print("Committed")

def __doCopyFromCmd():
    try:
        start=datetime.datetime.now()
        print("Start: %s" % start)
        print("Running in: %s" % (platform.platform()))
        args=__initArgs()
        __copy(args)
    finally:
        print("Ellapsed: %s" % (datetime.datetime.now()-start))

def doCopy():
    args=__getEnv()
    if __checkValues(args):
        __copy(args)

if  __name__ =='__main__':__doCopyFromCmd()