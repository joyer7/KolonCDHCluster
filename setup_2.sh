#! /bin/bash
echo "-- Start CM, it takes about 2 minutes to be ready"
systemctl start cloudera-scm-server

while [ `curl -s -X GET -u "admin:admin"  http://localhost:7180/api/version` -z ] ;
    do
    echo "waiting 10s for CM to come up..";
    sleep 10;
done

echo "-- Now CM is started and the next step is to automate using the CM API"

yum install -y epel-release
yum install -y python-pip
pip install --upgrade pip
pip install cm_client

sed -i "s/YourHostname/`hostname -f`/g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s/YourCDSWDomain/cdsw.$PUBLIC_IP.nip.io/g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s/YourPrivateIP/`hostname -I | tr -d '[:space:]'`/g" ~/KolonCDHCluster/$TEMPLATE
sed -i "s#YourDockerDevice#$DOCKERDEVICE#g" ~/KolonCDHCluster/$TEMPLATE

sed -i "s/YourHostname/`hostname -f`/g" ~/KolonCDHCluster/scripts/create_cluster.py

python ~/KolonCDHCluster/scripts/create_cluster.py $TEMPLATE

# configure and start EFM and Minifi
service efm start
#service minifi start

echo "-- At this point you can login into Cloudera Manager host on port 7180 and follow the deployment of the cluster"
