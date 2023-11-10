import subprocess
import shlex
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
from pathlib import Path

def lambda_handler(event, context):
    
    id = event['body']['id']
    format = event['body']['format']
    chunk = event['body']['chunk']
    chunkname = Path(chunk).stem
    bucket = event['body']['bucket']
    key = event['body']['key']

    # CREATE DIRECTORY FOR ENCODE
    create_directory = "mkdir -p /mnt/efs/" + id + "/encode/" + format
    command1 = shlex.split(create_directory)
    subprocess.run(command1, capture_output = True, text = True)
    logger.info('DIRECTORY CREATED IN EFS : /mnt/efs/' + id + '/encode/' + format)

    # ENCODE
    ffmpeg_cmd = "/opt/ffmpeg -i /mnt/efs/" + id + "/split/" + chunk + " -vn -ar 44100 -ac 2 -b:a 320k /mnt/efs/" + id + "/encode/" + format + '/' + chunkname + '.' + format
    command = shlex.split(ffmpeg_cmd)
    output = subprocess.run(command, capture_output = True, text = True)
    logger.info('FILE ENCODED : /mnt/efs/' + id + '/encode/' + format + '/' + chunkname + '.' + format)
    
    return {
        'statusCode': 200,
        'body': {
            'id': id,
            'format': format,
            'file' : chunkname + '.' + format,
            'path': '/mnt/efs/' + id + '/encode/' + format + '/' + chunkname + '.' + format,
            'bucket': bucket,
            'key': key
        }
    }