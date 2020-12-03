#from prometheus_client import start_http_server, Summary
import prometheus_client
import random
import time
import os
import sys

#LISTEN_PORT = 8008
if len(sys.argv)<2:
    sys.exit()

LISTEN_PORT = int( sys.argv[1]); #ugly, I know
# Create a metric to track time spent and requests made.
REQUEST_TIME = prometheus_client.Summary('request_processing_seconds', 'Time spent processing request')

#Counter 
count = prometheus_client.Counter('count', 'eBayChalengeCounter counter')
#Histogram 
#hist = prometheus_client.Histogram('histogram', 'eBayChalengeCounter histogram',buckets=(0.05, 0.1, 0.2, 0.5, 1, float("+Inf")))
hist = prometheus_client.Histogram('histogram', 'eBayChalengeCounter histogram')
gauge = prometheus_client.Gauge('gauge','eBayChalengeCounter dummy gauge',['resource_type'])


# Decorate function with metric.
@REQUEST_TIME.time()
def process_request(t):
	"""A dummy function that takes some time."""
	hist.observe(t)
	count.inc()
	time.sleep(t)
	gauge.labels('METRIC').set(t)
	
	
if __name__ == '__main__':
	# Start up the server to expose the metrics.
	prometheus_client.start_http_server(LISTEN_PORT)
	# Generate some requests.
	
	while True:
		process_request(random.random())
 

