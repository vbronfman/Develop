<<<<<<< HEAD
FROM busybox
ENTRYPOINT echo Here ls pwd hostname
=======
#image for pipeline
FROM ubuntu 

#do image configuration
RUN /bin/bush -c "echo have to be apt-get update or other configuration"
ENV myCustomEnv="enviromentvar1" \
    myOtherEnvVar='environment2"
>>>>>>> e55f97114d0da06a25cf60393f67b0e16521bd92
