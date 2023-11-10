import subprocess
import shlex
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
from pathlib import Path

def lambda_handler(event, context):
    
    id = event['body'][0]['body']['id']
    format = event['body'][0]['body']['format']
    bucket = event['body'][0]['body']['bucket']
    key = event['body'][0]['body']['key']

    # CREATE DIRECTORY FOR CONCAT
    create_directory = "mkdir -p /mnt/efs/" + id + "/concat/" + format
    command = shlex.split(create_directory)
    subprocess.run(command, capture_output = True, text = True)
    logger.info('DIRECTORY CREATED IN EFS : /mnt/efs/' + id + '/concat/' + format)

    # GET FILE LIST
    files = sorted(os.listdir('/mnt/efs/' + id + '/encode/' + format))
    logger.info('# FILE LIST')
    logger.info(files)

    # CREATE CONCAT FILE
    listFiles = []
    for file in files:
        listFiles.append("/mnt/efs/" + id + "/encode/" + format + "/" + file)
    concatString = '|'.join(listFiles)

    # CONCAT
    ffmpeg_cmd = '/opt/ffmpeg -i "concat:' + concatString + '" -safe 0 -c:a ' + format + ' -c copy /mnt/efs/' + id + '/concat/' + format + '/output.' + format
    command = shlex.split(ffmpeg_cmd)
    output = subprocess.run(command, capture_output = True, text = True)

    return {
        'statusCode': 200,
        'body': {
            'id': id,
            'format': format,
            'file' : 'output.' + format,
            'path': '/mnt/efs/' + id + '/concat/' + format + '/output.' + format,
            'bucket': bucket,
            'key': key
        }
    }