#!/usr/bin/env bash

PROMETHEUS_ROOT="/volume1/docker/monitoring"
PROMETHEUS_CONFIG_DIR="${PROMETHEUS_ROOT}/config"
PROMETHEUS_DATA_DIR="${PROMETHEUS_ROOT}/data"

mkdir -p ${PROMETHEUS_CONFIG_DIR}
mkdir -p ${PROMETHEUS_DATA_DIR}

# Create config directories
# Args :
#  * 1 - name of directory
function create_config_dir() {
  if [[ -z "${1}" ]]; then
    echo "Empty argument. Ignoring"
  fi

  [[ ! -d ${PROMETHEUS_CONFIG_DIR}/${1} ]] && mkdir -p ${PROMETHEUS_CONFIG_DIR}/${1} \
    && echo "config folder created for ${PROMETHEUS_CONFIG_DIR}/${1}"
}

# Create data directories
# Args :
#  * 1 - name of directory
#  * 2 - directory owner (uid:gid)
function create_data_dir() {
  if [[ -z "${1}" ]]; then
    echo "Empty argument. Ignoring"
  fi

  [[ ! -d ${PROMETHEUS_DATA_DIR}/${1} ]] && mkdir -p ${PROMETHEUS_DATA_DIR}/${1} \
    && echo "config folder created for ${PROMETHEUS_DATA_DIR}/${1}"

  if [[ ! -z "${2}" ]]; then
    echo "fixing directory owner"
    chown -R "${2}" "${PROMETHEUS_DATA_DIR}/${1}"
  fi
}

# Copy file to destination
# Args :
#  * 1 - source
#  * 2 - destination
function copy_file() {
  if [[ ! -f "${1}" ]]; then
    echo "Copying $(basename ${1})"
    cp ${1} ${PROMETHEUS_CONFIG_DIR}/${2}
  fi
}

create_config_dir "grafana"
create_data_dir   "grafana" "472:472"
copy_file config/grafana.ini ${PROMETHEUS_CONFIG_DIR}/grafana/grafana.ini

create_config_dir "prometheus"
create_data_dir   "prometheus" "65534:65534"

create_config_dir "alertmanager"
create_data_dir  "alertmanager" "65534:65534"
copy_file config/alertmanager.yml ${PROMETHEUS_CONFIG_DIR}/alertmanager/alertmanager.yml

create_config_dir "blackbox-exporter"
copy_file config/blackbox.yml ${PROMETHEUS_CONFIG_DIR}/blackbox-exporter/config.yml

create_config_dir "json-exporter"
copy_file config/json.yml ${PROMETHEUS_CONFIG_DIR}/json-exporter/config.yml


cp docker-compose.yml ${PROMETHEUS_ROOT}/docker-compose.yml

# Build containers
docker-compose -f ${PROMETHEUS_ROOT}/docker-compose.yml up -d

echo "
#############################################
Grafana       http://`hostname`:3000
Prometheus    http://`hostname`:9090
Alertmanager  http://`hostname`:9093
Node-Exporter http://`hostname`:9100/metrics
Json-Exporter http://`hostname`:7979
"
