import subprocess
import boto3
import shlex
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

import uuid

def lambda_handler(event, context):
    
    logger.info('## EVENT')
    logger.info(event)
    logger.info('## LOGS')
    s3 = boto3.client('s3')

    files = event['body']
    id = event['body'][0]['body']['id']

    # UPLOAD ORIGINAL FILE FROM EFS TO S3
    try:
        response = s3.upload_file('/mnt/efs/'+event['body'][0]['body']['id']+'/original/data', event['body'][0]['body']['bucket'], 'output/' + event['body'][0]['body']['id'] + '/original/data')
        print(f"File uploaded")
    except Exception as e:
        print(f"Error upload file: {str(e)}")

    # UPLOAD ENCODED FILE FROM EFS TO S3
    for file in files:
        try:
            response = s3.upload_file(file['body']['path'], file['body']['bucket'], 'output/' + file['body']['id'] + '/' + file['body']['format'] + '/output.' + file['body']['format'])
            print(f"File uploaded" + file['body']['path'])
        except Exception as e:
            print(f"Error upload file: {str(e)}")
    
    # DELETE DIRECTORY IN EFS
    create_directory = "rm -rf /mnt/efs/" + id
    command1 = shlex.split(create_directory)
    subprocess.run(command1, capture_output = True, text = True)
    logger.info('DIRECTORY DELETED IN EFS : /mnt/efs/' + id)
    
    return {
        'statusCode': 200,
        'body': {
            'id': id
        }
    }
