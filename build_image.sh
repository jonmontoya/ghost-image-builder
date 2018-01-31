#!/bin/bash
URL=$(jq -r '.url' config.json)
DOMAIN_NAME=$(echo $URL | grep -o '\([a-z]\+\.\)\{1,2\}[a-z]\+')
DEFAULT_IMAGE_NAME=${DOMAIN_NAME/./_}_ghost
IMAGE_NAME=${1:-$DEFAULT_IMAGE_NAME}

EMAIL=$(jq -r '.mail.from' config.json | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

if [ -z "$(echo $URL | grep -o 'https://')" ] ; then
  SSL=false
else
  SSL=true
fi

echo "Building Ghost Docker Image"
echo "==========================="
echo "URL: $URL"
echo "EMAIL: $EMAIL"
echo "DOMAIN_NAME: $DOMAIN_NAME"
echo "SSL: $SSL"
echo "IMAGE_NAME: $IMAGE_NAME"
echo "==========================="

docker image build \
--build-arg url=$URL \
--build-arg domain_name=$DOMAIN_NAME \
--build-arg email="$EMAIL" \
--build-arg ssl="$SSL" \
--tag $IMAGE_NAME .
