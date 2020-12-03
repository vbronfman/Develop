#FROM busybox:1.28 #i need with python one
#FROM python:3.8-slim-buster
FROM python:latest

#LABEL 

COPY exposer.py /exposer.py
#WORKDIR
#ARG EXPOSER=8000
ENV EXPOSER ${EXPOSER_PORT}

# Comment
RUN pip install psutil prometheus_client
#EXPOSE 8000 
#EXPOSE ${EXPOSER}

ENTRYPOINT python exposer.py ${EXPOSER}
#CMD ["exposer.py",${EXPOSER}]
#ENTRYPOINT ["python"]
#ENTRYPOINT /bin/bash