import json
import subprocess
import boto3
import shlex
import os
import glob
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

import uuid

def lambda_handler(event, context):
    
    logger.info('## EVENT')
    logger.info(event)
    logger.info('## LOGS')
    
    # GENERATE UUID FOR TRANSCODE
    id = str(uuid.uuid4())
    logger.info('CREATE ID FOR TRANSCODE: '+ id)
    
    # CREATE DIRECTORY FOR TRANSCODE
    create_directory = "mkdir -p /mnt/efs/" + id + "/original"
    command1 = shlex.split(create_directory)
    subprocess.run(command1, capture_output = True, text = True)
    logger.info('DIRECTORY CREATED IN EFS : /mnt/efs/' + id + '/original')

    # DOWNLOAD FILE FROM S3 in EFS
    s3 = boto3.client('s3')
    BUCKET_NAME = event['detail']['bucket']['name']
    KEY = event['detail']['object']['key']
    try:
        s3.download_file(BUCKET_NAME, KEY, '/mnt/efs/'+id+'/original/data')
        logger.info("File downloaded from s3")
    except Exception as e:
        logger.info("Error downloading file: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': {
            'id': id,
            'bucket': BUCKET_NAME,
            'key': KEY
        }
    }
