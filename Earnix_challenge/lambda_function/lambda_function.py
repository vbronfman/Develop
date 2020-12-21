import json
import os
from datetime import datetime

def lambda_handler(event, context):
    # TODO implement
    
    return {
        'statusCode': 200,
        'body': json.dumps('Time now is: '+ str(datetime.utcnow()) )
    }
