#!/usr/bin/python           # This is server.py file

import socket               # Import socket module
import threading
import pickle
import sys,os,subprocess
import logging
import re

'''
I'll certainly make it up better someday
'''

#from queue import Queue
bufsize=4096
port = 12345

logfile='server.log'
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    filename=logfile,
                    filemode='w')

console = logging.StreamHandler()
# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

if '--verbose' in sys.argv:
   console.setLevel(logging.INFO)
elif '--debug' in sys.argv:
    console.setLevel(logging.DEBUG)
else:
    console.setLevel(logging.ERROR)


logger = logging.getLogger(__name__)

logger.info('Started. Logfile: %s'%logfile)

  
def worker(conn,args):
   '''
   Run something in thread.
   receives 'pickled'/serialized object of what? 
   '''
   func_name=worker.__name__
   try:
      data_pickled=args #should be changed
      try:
         data = pickle.loads(data_pickled)
      except (pickle.UnpicklingError,pickle.PickleError) as p_error:
         logger.error("{} Pickling Exception catched! {}".format(func_name,p_error))
          #ugly way to provide an ability run command as plain string
         data={'oper': 'run','rcmd' : data_pickled.decode('utf-8')}
            
      
      logger.info ("Received: %s" % data)
      
      if data['oper'] and data['oper'] == 'run':
         [res,output]=run_cmd(data['rcmd'])
         logger.debug('after cmd res=%s'%res)
      
      response=output
   
      #send responce back to client
      #if string send back raw string
      if isinstance(data_pickled, str):
      #if isinstance(data_pickled.decode('utf-8'), str):
         logger.debug("is string")
      #bytes(input_msg, "utf-8")
         #conn.sendall(str.encode(response))
         conn.sendall(bytes(response, "utf-8"))
      else:
         #prepare a simple dict (should be an object)
         data_back={}
         data_back['ret_code']=res
         data_back['data']=output
         data_pickled = pickle.dumps(data_back)
         conn.sendall(data_pickled)
      #conn.send(message)
      conn.send(b'Thank you for connecting')
      conn.close()                         # Close the connection 
   
   except Exception as error:
      logger.error("{} Exception catched! {}".format(func_name,error))
      
   return

def run_cmd(cmd):
   res=None
   output=None
   
   try:
        func_name=run_cmd.__name__
        logger.info(func_name)
            
        p=subprocess.Popen([cmd],universal_newlines=True, shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
                
        logger.info([cmd])
        output, error = p.communicate()

#        output = p.stdout.read()
#        error=p.stderr.read()
        
        logger.info(output)
        logger.info("return code = {}".format( p.returncode))
        res=p.returncode
        if p.returncode != 0:
            logger.info("{}:{}".format(func_name,error))
            
            #logger.info(streamdata)
            logger.error("cmd {} failed".format(cmd))

   except Exception as error:
      res=False
      logger.error("Cought exception {}: {}".format(func_name,error))
      output=str(error)
      
   return [res,output]

#####
# main
def main():
   func_name=__name__
   s = socket.socket()         # Create a socket object
   host = socket.gethostname() # Get local machine name
                  # Reserve a port for your service.
   
   
   s.bind((host, port))        # Bind to the port
   
   s.listen(5)                 # Now wait for client connection.
   while True:
      conn, addr = s.accept()     # Establish connection with client.
      try:
         #create thread and continue
         
         logger.info( 'Got connection from %s'%[ addr])
            
         message=conn.recv(bufsize) #have to verify the number!
               
         t = threading.Thread(target=worker,args=(conn,message,))
         t.daemon = True  # thread dies when main thread (only non-daemon thread) exits.
         t.start()
               
      
            
      except Exception as error:
         logger.error("{} Exception catched! {}".format(func_name,error))
         if conn:
            conn.close()
   
   
if __name__ == '__main__':
    main()  
 