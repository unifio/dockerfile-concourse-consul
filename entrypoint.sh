#!/bin/bash

if [ ! -z "$CONSUL_PREFIX" ]; then
  if [ $1 = "web" ]; then
    concourse_keys=(authorized_worker_keys session_signing_key tsa_host_key)
    for i in ${concourse_keys[@]}; do
      echo -e "{{key \"${CONSUL_PREFIX}/tls/${i}\"}}\n" > /tmp/key.ctmpl
      /usr/local/bin/consul-template -template "/tmp/key.ctmpl:/concourse-keys/${i}" -once
    done

    CONCOURSE_DB_USER=`/usr/local/bin/envconsul -sanitize -pristine -upcase -once -prefix ${CONSUL_PREFIX}/${1} env | grep CONCOURSE_DB_USER | cut -c 19-`
    CONCOURSE_DB_PASSWORD=`/usr/local/bin/envconsul -sanitize -pristine -upcase -once -prefix ${CONSUL_PREFIX}/${1} env | grep CONCOURSE_DB_PASSWORD | cut -c 23-`
    export CONCOURSE_POSTGRES_DATA_SOURCE="postgres://${CONCOURSE_DB_USER}:${CONCOURSE_DB_PASSWORD}@${CONCOURSE_DB_ENDPOINT}?sslmode=disable"
  elif [ $1 = "worker" ]; then
    concourse_keys=(tsa_host_key_pub worker_key)
    for i in ${concourse_keys[@]}; do
      echo -e "{{key \"${CONSUL_PREFIX}/tls/${i}\"}}\n" > /tmp/key.ctmpl
      /usr/local/bin/consul-template -template "/tmp/key.ctmpl:/concourse-keys/${i}" -once
    done
  fi
  /usr/local/bin/envconsul -prefix $CONSUL_PREFIX/$1 -sanitize -upcase -once /usr/local/bin/concourse "$@"
else
  /usr/local/bin/concourse "$@"
fi
