#!/bin/bash
set -e

# Ideally move all this to a proper config management tool
#
# Configure kibana

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

cat <<'EOF' >/etc/yum.repos.d/kibana.repo
[kibana-${kibana_version}]
name=Kibana repository for ${kibana_version}.x packages
baseurl=http://packages.elastic.co/kibana/${kibana_version}/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF

sudo yum install -y kibana
sudo /opt/kibana/bin/kibana plugin --install elasticsearch/marvel/latest

# Configure the consul agent
cat <<EOF >/tmp/consul.json
{
    "addresses"                   : {
        "http" : "0.0.0.0"
    },
    "recursor"                    : "${dns_server}",
    "disable_anonymous_signature" : true,
    "disable_update_check"        : true,
    "data_dir"                    : "/mnt/consul/data"
}
EOF
sudo mv /tmp/consul.json /etc/consul.d/consul.json

# Setup the consul agent init script
cat <<'EOF' >/tmp/upstart
description "Consul agent"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

env PIDFILE=/var/run/consul.pid

script
  # Make sure to use all our CPUs, because Consul can block a scheduler thread
  export GOMAXPROCS=`nproc`

  # Get the IP
  BIND=`ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }'`

  echo $$ > $${PIDFILE}
  exec /usr/local/bin/consul agent \
    -config-dir="/etc/consul.d" \
    -bind=$${BIND} \
    -node="kibana-$${BIND}" \
    -dc="${consul_dc}" \
    -atlas=${atlas} \
    -atlas-join \
    -atlas-token="${atlas_token}" \
    >>/var/log/consul.log 2>&1
end script

# to gracefully remove agents
pre-stop script
    [ -e $PIDFILE ] && kill -INT $(cat $PIDFILE)
    rm -f $PIDFILE
end script
EOF
sudo mv /tmp/upstart /etc/init/consul.conf

# Setup the consul agent config
cat <<'EOF' >/tmp/kibana-consul.json
{
    "service": {
        "name": "kibana",
        "leave_on_terminate": true,
        "tags": [
            "http", "index"
        ],
        "port": 5601,
        "checks": [{
            "id": "1",
            "name": "Kibana HTTP",
            "notes": "Use curl to check the web service every 10 seconds",
            "script": "curl `ifconfig eth0 | grep 'inet addr' | awk '{ print substr($2,6) }'`:5601 >/dev/null 2>&1",
            "interval": "10s"
        }]
    }
}
EOF
sudo mv /tmp/kibana-consul.json /etc/consul.d/kibana.json

# Start Kibana
sudo chkconfig --add kibana
sudo service kibana start

# Start Consul
sudo start consul

