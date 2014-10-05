#!/usr/bin/python           # This is client.py file

# raw version should be refactored


import socket               # Import socket module
import pickle
import sys
import argparse
import logging

__version__ = "1.0.0"

logging.basicConfig(level=logging.DEBUG)
logger=logging.getLogger(__name__)
logger.info('Start')
def main():
    #[progname,server,input_msg] = (sys.argv)
     
    args=get_opts()
    s = socket.socket()         # Create a socket object
    #host = socket.gethostname() # Get local machine name
    host = socket.gethostbyname(args['server'])
    port = 12345                # Reserve a port for your service.
    s.settimeout(60)
    
    try:
        s.connect((host, port))
        
        data_pickled = pickle.dumps(args)
        #s.sendall(bytes(input_msg, "utf-8"))
        s.sendall(data_pickled)
    
        total_data=[]
        #while True:
        #    data = s.recv(1024)
        #    if not data: break
        #    total_data.append(data)
        
        data = s.recv(4096) #what is a buffersize should be?
        response = pickle.loads(data) #serialize 
        
        logger.info( "Response ret_code={}".format(response['ret_code']))
        logger.debug( "Response data={}".format(response['data']))
        
    except socket.error as msg :
        print ("Exception cought: %s" % msg)
    except (pickle.UnpicklingError,pickle.PickleError) as p_error:
         print("{} Pickling Exception catched! {}".format(func_name,p_error))
    except Exception as error:
        print ("Common Exception cought",error)
    finally:
        s.close       # Close the socket when done
        return False
    
def get_opts():
    '''
    Preparate program arguments
    '''
    
    func_name=get_opts.__name__
    ret=None
    
    try:
        parser = argparse.ArgumentParser( description='ITLabClient.{}'.format(__version__))
    
        parser.add_argument('--oper', dest='oper',required=True, 
                       help='Operation to perform')
        parser.add_argument('--dhost', dest='server',action='store',
                       required=True, help='Destination host')
        parser.add_argument('--cmd', dest='rcmd', nargs='?', action='store',
                            required=True, help='Command to run at remote host')
#        parser.add_argument('--product_name', dest='prod', nargs='?', action='store',
#                       required=True, help='Name of Product to process')
##Check the conf_file's value is proper and assign default value if doesn't
#        parser.add_argument('--conf_file', dest='config_file', action='store',
#                       default=settings.CONFIG_FILE,nargs='?',type=file_exist,
#                       help='Config file')
        parser.add_argument('--debug', help='Debug level output', action='store_true')
        parser.add_argument('--verbose', help='Verbose output', action='store_true')

    
        args = parser.parse_args()

    # to have dict-like view of the attributes
        ret=vars(parser.parse_args())
    except argparse.ArgumentTypeError as error:
        #raise 
        #logger.error ("Cought exception!!!" )
        print ("Cought exception!!! ArgumentTypeError" )
        ret=False

    return ret

if __name__ == '__main__':
    main()