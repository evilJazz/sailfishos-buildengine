FROM alpine

COPY tools/* /
RUN chmod +x /runmersdkengine.sh

EXPOSE 2222
EXPOSE 8080

ENTRYPOINT ["/runmersdkengine.sh"]
