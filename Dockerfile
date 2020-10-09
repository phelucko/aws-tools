FROM python:alpine

RUN set -o errexit -o nounset \
  && apk -v --update add \
    musl-dev \
    gcc \
    shadow \
    git \
    docker \
    less \
    groff \
  && pip install awscli aws-sam-cli \
  && apk del musl-dev gcc \
  && rm /var/cache/apk/*

RUN set -o errexit -o nounset \
  && mkdir -p /src/aws \
  && echo "Adding aws user and group" \
  && addgroup -S -g 1000 aws \
  && adduser -S aws -G aws -u 1000 -s /bin/sh -h /home/aws \
  && adduser aws docker \
  && mkdir /home/aws/.aws \
  && chown --recursive aws:aws /home/aws

COPY run.sh /usr/local/bin/

WORKDIR /src/aws

ENTRYPOINT ["/usr/local/bin/run.sh"]
