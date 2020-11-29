#!/bin/bash

GOTIFY_DATA_DIR=/volume1/docker/gotify

if [[ ! -d "${GOTIFY_DATA_DIR}" ]]; then
	echo "Creating directory"
	mkdir -p ${GOTIFY_DATA_DIR}
fi

sed "s#ROOT#${GOTIFY_DATA_DIR}#" docker-compose.tmpl > docker-compose.yml

docker-compose -f docker-compose.yml up -d
