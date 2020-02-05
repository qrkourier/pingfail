FROM alpine:edge

RUN apk add --update --no-cache python3 bash && \
    pip3 install --upgrade pip setuptools httpie && \
    rm -r /root/.cache

COPY ./pingfail.sh /
COPY ./index-template.json /

#ENTRYPOINT [ "http" ]
CMD ["/pingfail.sh"]
