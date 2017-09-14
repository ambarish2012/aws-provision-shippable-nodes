#! /bin/bash -e

# parameters passed in
API_TOKEN=$1

# get clusterNodeId 
export RESPONSE=$(curl --request GET \
  --url https://api.shippable.com/clusterNodes \
  --header "authorization: apiToken $API_TOKEN" \
  --header "cache-control: no-cache" \
  --header "content-type: application/json" )

# extract the cluster node id from the response
CLUSTER_NODE_ID=$(echo $RESPONSE | jq -r '.[] | select(.friendlyName=="{{ item }}")'.id)

# deregister node from Shippable
curl --request DELETE \
  --url https://api.shippable.com/clusterNodes/${CLUSTER_NODE_ID} \
  --header "authorization: apiToken $API_TOKEN" 
