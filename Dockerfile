#image for pipeline
FROM ubuntu 

#do image configuration
RUN /bin/bush -c "echo have to be apt-get update or other configuration"
ENV myCustomEnv="enviromentvar1" \
    myOtherEnvVar='environment2"
