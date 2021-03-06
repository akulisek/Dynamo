#/bin/bash

#################################
# configuration variables
################################

# default parameters

VM_1="null"
DS_IP="null"
PROXY="proxy"
VM_1="null"
NETWORK_NAME="private-network"
NETWORK="192.168.0.0/24"

# arguments
while (( "$#" ));
do
    PARAM="$1";
    VALUE="$2";
    case $PARAM in
	-n)     
		NETWORK="$VALUE"
		;;
	-nName) 
		NETWORK_NAME="$VALUE" 
		;;
	-name)

		PROXY="$VALUE"
		;;
	-image)

		NG_IMAGE="$VALUE"
		;;
	-vm)
		VM_1="$VALUE"
		;;
	-ds)
		DS_IP="$VALUE"
		;;
    esac	
    shift
done

#############################################
# creating nginx
#############################################

ID_CONTAINER=$[RANDOM % 10 + 1]
UUID=$(uuidgen)
IP=$(docker-machine ip $VM_1)
echo "tu3"
eval $(docker-machine env $VM_1)
docker run -itd -p 80:80 --name=$PROXY$ID_CONTAINER --net=$NETWORK_NAME --env="constraint:node==$VM_1" ng
echo "tu"
json="{ \"ID\": \"$UUID\", \"Name\": \"$PROXY\", \"Address\": \"$IP\", \"Port\": 80, \"check\": { \"name\": \"web-proxy\",  \"http\": \"http://$IP:80/health/\", \"interval\": \"10s\", \"timeout\": \"5s\", \"status\": \"passing\"}}"

echo $json > ./temporary.json

curl -X PUT --data-binary @temporary.json http://$DS_IP:8500/v1/agent/service/register

rm ./temporary.json


