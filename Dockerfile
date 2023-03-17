FROM concourse/concourse:2.5.0
MAINTAINER Unif.io, Inc. <support@unif.io>

ENV CONCOURSE_TSA_PUBLIC_KEY         /concourse-keys/tsa_host_key_pub

ENV ENVCONSUL_VERSION=0.6.1
ENV CONSULTEMPLATE_VERSION=0.16.0

RUN apt-get update && \
    apt-get -y upgrade ca-certificates curl unzip && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    curl -s --output envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip && \
    curl -s --output envconsul_${ENVCONSUL_VERSION}_SHA256SUMS https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_SHA256SUMS && \
    curl -s --output envconsul_${ENVCONSUL_VERSION}_SHA256SUMS.sig https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_SHA256SUMS.sig && \
    curl -s --output consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip && \
    curl -s --output consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS && \
    curl -s --output consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys C874011F0AB405110D02105534365D9472D7468F && \
    gpg --batch --verify envconsul_${ENVCONSUL_VERSION}_SHA256SUMS.sig envconsul_${ENVCONSUL_VERSION}_SHA256SUMS && \
    gpg --batch --verify consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS && \
    grep envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip envconsul_${ENVCONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    grep consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /usr/local/bin envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip && \
    unzip -d /usr/local/bin consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    rm -rf /tmp/build

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/entrypoint.sh"]
