#! /bin/bash -e

# parameters passed in
API_TOKEN=$1
SUBSCRIPTION_ID=$2
  # value must match file in https://github.com/Shippable/node/tree/master/scripts
OS_DOCKER=ubu_16.04_docker_1.13.sh

# retrieve AWS instance id and external IP address for instance
FRIENDLY_NAME=$(wget -q -O - http://instance-data/latest/meta-data/instance-id)
IP_ADDRESS=$(dig +short myip.opendns.com @resolver1.opendns.com)

# register the new node with Shippable via POST route
export RESPONSE=$(curl --request POST \
  --url https://api.shippable.com/clusterNodes \
  --header "authorization: apiToken $API_TOKEN" \
  --header "cache-control: no-cache" \
  --header "content-type: application/json" \
  --data "{\"subscriptionId\": \"$SUBSCRIPTION_ID\",\"friendlyName\": \"$FRIENDLY_NAME\",\"location\": \"$IP_ADDRESS\",\"nodeInitScript\": \"$OS_DOCKER\",\"initializeSwap\": false,\"nodeTypeCode\": 7000,\"isShippableInitialized\": false}")

# extract the cluster node id from the response
CLUSTER_NODE_ID=$(echo $RESPONSE | jq -r '.id')

# download the initialization script from Shippable for this node
if [[ ! -f shipInitNode.sh ]]; then
  curl -o ./shipInitNode.sh --request GET https://api.shippable.com/clusterNodes/$CLUSTER_NODE_ID/initScript \
    --header "authorization: apiToken $API_TOKEN" \
    --header "cache-control: no-cache" \
    --header "content-type: application/json"
fi;

# make the init script executable
sudo chmod +x shipInitNode.sh

# run the init script
sudo ./shipInitNode.sh
