#!/bin/bash

sudo apt-get install jq -y || sudo yum install jq -y

# Wait for Rancher UI to boot
printf 'Waiting for Rancher to start'
until $(curl --output /dev/null --silent --head --fail ${rancher_host}); do
    printf '.'
    sleep 5
done

# Setup api.host
curl -X PUT \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-d '{"id":"api.host","type":"activeSetting","baseType":"setting","name":"api.host","activeValue":null,"inDb":false,"source":null,"value":"http://${primary_ip}:8080"}' \
	'${rancher_host}/v2-beta/settings/api.host'

# Update default registry to private registry if requested
if [ "${rancher_registry}" != "" ]; then
	curl -X PUT \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '{"id":"registry.default","type":"activeSetting","baseType":"setting","name":"registry.default","activeValue":"","inDb":false,"source":"Code Packaged Defaults","value":"${rancher_registry}"}' \
		'${rancher_host}/v2-beta/settings/registry.default'
fi

# Update default catalogs (library/community) to point directly to github repos
curl -X PUT \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-d '{"activeValue":"{\"catalogs\":{\"library\":{\"url\":\"https://github.com/rancher/rancher-catalog.git\", \"branch\":\"v1.6-release\"}, \"community\":{\"url\":\"https://github.com/rancher/community-catalog.git\", \"branch\":\"master\"}}}", "id":"catalog.url", "name":"catalog.url", "source":"Database", "value":"{\"catalogs\":{\"library\":{\"url\":\"https://github.com/rancher/rancher-catalog.git\", \"branch\":\"v1.6-release\"}, \"community\":{\"url\":\"https://github.com/rancher/community-catalog.git\", \"branch\":\"master\"}}}"}' \
	'${rancher_host}/v2-beta/settings/catalog.url'
curl -X PUT \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-d '{"activeValue":"{\"catalogs\":{\"community\":{\"url\":\"https://github.com/rancher/community-catalog.git\", \"branch\":\"master\"}, \"library\":{\"url\":\"https://github.com/rancher/rancher-catalog.git\", \"branch\":\"v1.6-release\"}}}", "id":"default.cattle.catalog.url", "name":"default.cattle.catalog.url", "source":"Environment Variables", "value":"{\"catalogs\":{\"community\":{\"url\":\"https://github.com/rancher/community-catalog.git\",\"branch\":\"master\"}, \"library\":{\"url\":\"https://github.com/rancher/rancher-catalog.git\", \"branch\":\"v1.6-release\"}}}"}' \
	'${rancher_host}/v2-beta/settings/default.cattle.catalog.url'

# Delete default cattle environment
curl -X POST \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-d '{}' \
	'${rancher_host}/v2-beta/projects/1a5/?action=deactivate'

sleep 5

curl -X DELETE \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-d '{}' \
	'${rancher_host}/v2-beta/projects/1a5/?action=delete'
