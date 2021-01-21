FROM python:slim-buster

RUN set -o errexit -o nounset \
  && apt-get update -y \
  && apt-get install -y -q curl unzip git groff \
  && pip install aws-sam-cli

RUN set -o errexit -o nounset \
  && echo "Installing docker" \
  && apt-get update -y \
  && apt-get install -y -q apt-transport-https ca-certificates \
  gnupg2 software-properties-common \
  && curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" \
  && apt-get update -y \
  && apt-get install -y -q docker-ce \
  && apt-get clean \
  && rm -f /var/lib/apt/lists/*_*

RUN set -o errexit -o nounset \
  && echo "Installing aws-cli" \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
  && unzip -d /tmp /tmp/awscliv2.zip \
  && /tmp/aws/install \
  && curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb" \
  && dpkg -i /tmp/session-manager-plugin.deb \
  && rm -rf /tmp/aws && rm -f /tmp/awscliv2.zip /tmp/session-manager-plugin.deb

RUN set -o errexit -o nounset \
  && mkdir -p /src/aws \
  && echo "Adding aws user and group" \
  && groupadd --system -g 1000 aws \
  && useradd --system -g aws -u 1000 -s /bin/sh -d /home/aws aws \
  && usermod -a -G docker aws \
  && mkdir -p /home/aws/.aws \
  && chown --recursive aws:aws /home/aws

COPY run.sh /usr/local/bin/

WORKDIR /src/aws

ENTRYPOINT ["/usr/local/bin/run.sh"]
