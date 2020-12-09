#!/usr/bin/env bash

source ../env


GRAFANA_ROOT=${APP_ROOT}/grafana
install -d -m 0755 ${GRAFANA_ROOT}/config
install -d -o 472 -g 472 -m 0755 ${GRAFANA_ROOT}/data
install config/grafana.ini ${GRAFANA_ROOT}/config/

PROMETHEUS_ROOT=${APP_ROOT}/prometheus
install -d -m 0755 ${PROMETHEUS_ROOT}/config
install -d -o 65534 -g 65534 -m 0755 ${PROMETHEUS_ROOT}/data

ALERTMANAGER_ROOT=${APP_ROOT}/alertmanager
install -d -m 0755 ${ALERTMANAGER_ROOT}/config
install -d -m 0755 ${ALERTMANAGER_ROOT}/data
install config/alertmanager.yml ${ALERTMANAGER_ROOT}/config/

BLACKBOX_ROOT=${APP_ROOT}/blackbox-exporter
install -d -m 0755 ${BLACKBOX_ROOT}/config
install config/blackbox.yml ${BLACKBOX_ROOT}/config/config.yml

JSON_ROOT=${APP_ROOT}/json-exporter
install -d -m 0755 ${JSON_ROOT}/config
install config/json.yml ${JSON_ROOT}/config/config.yml

# TODO: node-exporter, data directory for text files. 

cp docker-compose.yml ${APP_ROOT}/docker-compose.yml

# Build containers
docker-compose -f ${APP_ROOT}/docker-compose.yml up -d

echo "
#############################################
Grafana       http://`hostname`:3000
Prometheus    http://`hostname`:9090
Alertmanager  http://`hostname`:9093
Node-Exporter http://`hostname`:9100/metrics
Json-Exporter http://`hostname`:7979
"
