#! /bin/bash
TEMPLATE=$1
# ugly, but for now the docker device has to be put by the user
DOCKERDEVICE=$2

# Cloudera Manager Install
yum install -y epel-release
yum install -y python-pip
pip install --upgrade pip
pip install cm_client
sed -i "s/YourHostname/`hostname -f`/g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s/YourCDSWDomain/cdsw.$PUBLIC_IP.nip.io/g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s/YourPrivateIP/`hostname -I | tr -d '[:space:]'`/g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s#YourDockerDevice#$DOCKERDEVICE#g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s/YourHostname/`hostname -f`/g" ~/KolonCDHCluster/scripts/create_cluster.py

# Create Cluster
# Python Installation
python ~/KolonCDHCluster/scripts/create_cluster.py $TEMPLATE

# configure and start EFM and Minifi
service efm start
#service minifi start

echo "-- At this point you can login into Cloudera Manager host on port 7180 and follow the deployment of the cluster"
