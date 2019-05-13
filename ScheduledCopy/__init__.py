import datetime
import logging

import azure.functions as func

from . import copys3toaz


def main(mytimer: func.TimerRequest) -> None:
    #class Object(object):
    #    pass
    #mytimer=Object()
    #mytimer.past_due=True
    #req: func.HttpRequest
    
    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    if mytimer.past_due:
        logging.info('The timer is past due!')

    copys3toaz.doCopy()

    logging.info('Python timer trigger function ran at %s', utc_timestamp)
