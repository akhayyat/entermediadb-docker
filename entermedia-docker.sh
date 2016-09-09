#!/bin/bash 
#To run this script: sudo ./create.sh xyzcorp 8888
OPERATION=$1
SITE=$2
PORT=$3

#TODO support creating, upgrading, start, stop and removing

ENDPOINT=/media/emsites/${SITE}

# Create entermedia user if needed
groupadd entermedia > /dev/null
useradd -g entermedia entermedia > /dev/null
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Make site mount area 
sudo mkdir -p ${ENDPOINT}/assets
sudo mkdir -p ${ENDPOINT}/data
sudo mkdir -p ${ENDPOINT}/tomcat${PORT}
sudo mkdir -p ${ENDPOINT}/elastic
sudo echo "sudo docker start ${SITE}${PORT}" > ${ENDPOINT}/start.sh
sudo echo "sudo docker exec -it ${SITE}${PORT} /opt/entermediadb/tomcat/bin/shutdown.sh" > ${ENDPOINT}/stop.sh
sudo echo "sudo docker logs -f --tail 500 ${SITE}${PORT}"  > ${ENDPOINT}/logs.sh
sudo echo "sudo docker exec -it ${SITE}${PORT} bash"  > ${ENDPOINT}/bash.sh

sudo echo "sudo docker exec -it ${SITE}${PORT} /opt/entermediadb/tomcat/bin/shutdown.sh" > ${ENDPOINT}/update.sh
sudo echo "sudo docker rm ${SITE}${PORT}" >> ${ENDPOINT}/update.sh
sudo echo "sudo docker pull entermediadb/entermediadb9" >> ${ENDPOINT}/update.sh
sudo echo "sudo wget -O entermedia-docker.sh  https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/entermedia-docker.sh" >> ${ENDPOINT}/update.sh
sudo echo "sudo sh ./entermedia-docker.sh create ${SITE} ${PORT}" >> ${ENDPOINT}/update.sh

sudo chmod 755 ${ENDPOINT}/*.sh

# Fix permissions
sudo chown -R entermedia. "${ENDPOINT}"

echo "Creating new EnterMedia container ${SITE}${PORT}"
# Run Create Docker Instance, add Mounted HotFolders as needed
sudo docker run -t -d --name ${SITE}${PORT} \
	-p $PORT:$PORT \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/assets:/opt/entermediadb/webapp/assets \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/tomcat${PORT}:/opt/entermediadb/tomcat \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb/entermediadb9:latest
