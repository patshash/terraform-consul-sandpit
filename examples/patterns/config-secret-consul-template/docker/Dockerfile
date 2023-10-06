FROM alpine
ENV LOG_LEVEL=INFO
ENV PRODUCT_VERSION=0.33.0
ENV PRODUCT_DIST=linux
ENV PRODUCT_ARCH=amd64
ENV DOWNLOAD_URL=https://releases.hashicorp.com/consul-template/${PRODUCT_VERSION}/consul-template_${PRODUCT_VERSION}_${PRODUCT_DIST}_${PRODUCT_ARCH}.zip

RUN apk add unzip && \
apk add wget && \
wget -q $DOWNLOAD_URL -O /tmp/consul-template.zip && \
unzip /tmp/consul-template.zip -d /usr/local/bin/

CMD consul-template -template=$TEMPLATE_PATH:$RESULT_PATH -log-level=$LOG_LEVEL $EXTRA_ARGS