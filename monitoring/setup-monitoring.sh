#!/usr/bin/env sh

PROMETHEUS_ROOT="/volume1/docker/monitoring"
PROMETHEUS_CONFIG_DIR="${PROMETHEUS_ROOT}/config"
PROMETHEUS_DATA_DIR="${PROMETHEUS_ROOT}/data"

mkdir -p ${PROMETHEUS_CONFIG_DIR}
mkdir -p ${PROMETHEUS_DATA_DIR}

# Create config directories
echo "Configuration directories creation"
configs=( "prometheus" "alertmanager" "blackbox-exporter" "json-exporter" )
for app in "${configs[@]}"; do
   [[ ! -d ${PROMETHEUS_CONFIG_DIR}/${app} ]] && mkdir -p ${PROMETHEUS_CONFIG_DIR}/${app} \
     && echo "config folder created for ${PROMETHEUS_CONFIG_DIR}/${app}"
done
echo "OK."

# Create data directories
echo "Data directories creation"
datas=( "prometheus" "alertmanager" )
for app in "${datas[@]}"; do
  [[ ! -d ${PROMETHEUS_DATA_DIR}/${app} ]] && mkdir -p ${PROMETHEUS_DATA_DIR}/${app} \
    && echo "config folder created for ${PROMETHEUS_DATA_DIR}/${app}"
done
echo "OK."

echo "Fixing directory permissions" 
chown 65534:65534 ${PROMETHEUS_DATA_DIR}/prometheus #nobody userid
chown 65534:65534 ${PROMETHEUS_DATA_DIR}/alertmanager #nobody userid

echo "Copying extra files"
if [[ ! -f "${PROMETHEUS_CONFIG_DIR}/alertmanager/alertmanager.yml" ]]; then
  echo "Copying alertmanager config"
  cp config/alertmanager.yml ${PROMETHEUS_CONFIG_DIR}/alertmanager/alertmanager.yml
fi

if [[ ! -f "${PROMETHEUS_CONFIG_DIR}/json-exporter/config.yml" ]]; then
  echo "Copying json exporter config"
  cp config/json.yml ${PROMETHEUS_CONFIG_DIR}/json-exporter/config.yml
fi

if [[ ! -f "${PROMETHEUS_CONFIG_DIR}/blackbox-exporter/config.yml" ]]; then
  echo "Copying blackbox exporter config"
  cp config/blackbox.yml ${PROMETHEUS_CONFIG_DIR}/blackbox-exporter/config.yml
fi

sed "s#ROOT#${PROMETHEUS_ROOT}#" docker-compose.yml > ${PROMETHEUS_ROOT}/docker-compose.yml

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
