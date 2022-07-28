from ubuntu:20.04

ARG version=latest

RUN apt update && apt install -y curl

ENV KIVERA_PATH=/opt/kivera/bin
ENV KIVERA_CREDENTIALS=/opt/kivera/etc/credentials.json
ENV KIVERA_CA_CERT=/opt/kivera/etc/ca-cert.pem
ENV KIVERA_CA=/opt/kivera/etc/ca.pem
ENV KIVERA_CERT_TYPE=ecdsa
ENV KIVERA_LOGS_FILE=/opt/kivera/var/log/proxy.log

COPY entrypoint.sh /
COPY custom.sh /

WORKDIR /home/kivera
EXPOSE 8080/tcp 8090/tcp

# Install Kivera
ADD https://download.kivera.io/binaries/proxy/linux/amd64/kivera-$version.tar.gz /tmp/kivera.tar.gz

RUN tar -xvzf /tmp/kivera.tar.gz -C /tmp \
    && cp /tmp/bin/linux/amd64/kivera $KIVERA_PATH/kivera

# Configure permissions
RUN adduser --system --group kivera \
    && mkdir -p /opt/kivera/etc /opt/kivera/var/log \
    && chown -R kivera:kivera /opt/kivera \
    && chmod ug+x /opt/kivera/bin/kivera /opt/kivera/bin/entrypoint.sh

# Configure logging agent
RUN curl -o td-agent-apt-source.deb https://packages.treasuredata.com/4/ubuntu/focal/pool/contrib/f/fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb
RUN apt install -y ./td-agent-apt-source.deb
RUN apt update && apt install -y td-agent
RUN /usr/sbin/td-agent-gem install fluent-plugin-out-kivera
COPY fluent.conf /etc/td-agent/td-agent.conf

# Entrypoint
USER kivera
ENTRYPOINT ["/entrypoint.sh"]
