#FROM busybox:1.28 #i need with python one
#FROM python:3.8-slim-buster
FROM python:latest

LABEL maintainer="vlad.bronfman@gmail.com"

COPY exposer.py /exposer.py
#WORKDIR
#ENV
# Comment
#RUN echo 'we are running some # of cool things'
RUN pip install psutil prometheus_client
#EXPOSE 8000
EXPOSE ${EXPOSER}

ENTRYPOINT python exposer.py 
#ENTRYPOINT /bin/bash