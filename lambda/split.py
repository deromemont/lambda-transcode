import subprocess
import shlex
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    
    logger.info('## EVENT')
    logger.info(event)
    logger.info('## LOGS')

    id = event['body']['id']
    bucket = event['body']['bucket']
    key = event['body']['key']

    # CREATE DIRECTORY FOR SPLIT
    create_directory = "mkdir -p /mnt/efs/" + id + "/split"
    command1 = shlex.split(create_directory)
    subprocess.run(command1, capture_output = True, text = True)
    logger.info('DIRECTORY CREATED IN EFS : /mnt/efs/' + id + '/split')

    # SPLIT FILE
    ffmpeg_cmd = "/opt/ffmpeg -i /mnt/efs/" + id + "/original/data -f segment -segment_time 10 -c copy /mnt/efs/" + id + "/split/out%03d.flac"
    command = shlex.split(ffmpeg_cmd)
    output = subprocess.run(command, capture_output = True, text = True)

    # GET ALL FILES
    dirs = sorted(os.listdir('/mnt/efs/' + id + '/split'))

    p4 = subprocess.run(['ls', '-al', '/mnt/efs/'+id+'/split'], capture_output = True, text = True)
    logger.info("# RESULT LS -AL")
    logger.info(p4.stdout)
    
    return {
        'statusCode': 200,
        'body': {
            'id': id,
            'chunks': dirs,
            'outputFormat': ['mp3', 'mp2', 'wav', 'flac'],
            'bucket': bucket,
            'key': key
        }
    }
