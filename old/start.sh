#!/bin/bash

typeset dir=$(pwd)
typeset script=$0

# preconditions
if ! [[ -d "${dir}/rrd-data/" ]]; then
    printf "cannot find directory 'rrd-data' inside current directory (contains rrd graph databases)"
    exit 2
fi
if ! [[ -d "${dir}/sensitive-data/" ]]; then
    printf "cannot find directory 'sensitive-data' inside current directory"
    exit 2
fi
if ! [[ -f "${dir}/sensitive-data/resource.cfg" ]]; then
    printf "cannot find file 'sensitive-data/resource.cfg' inside current directory (contains passwords for nagios)"
    exit 2
fi
#if ! [[ -f "${dir}/sensitive-data/deployment.id_rsa" ]]; then
#    printf "cannot find file 'sensitive-data/deployment.id_rsa' inside current directory (contains private key for accessing DPP servers)"
#    exit 2
#fi


typeset host=$(boot2docker ip 2>/dev/null)
if ! [[ "$host" ]]; then
    host="localhost"
fi

echo "attempting to launch rayburgemeestre/nagiosnagvis at: http://$host:7000/"

# nagios(1000) staff(50)
sudo chown -R 1000:50 ${dir}/sensitive-data
sudo chmod -R     755 ${dir}/sensitive-data
sudo chown -R 1000:50 ${dir}/rrd-data
sudo chmod -R     755 ${dir}/rrd-data

if [[ $script = *dev* ]]; then
    docker run $* -p 7000:80 -t -i \
        -v ${dir}/rrd-data/:/usr/local/nagiosgraph/var/rrd \
        -v ${dir}/sensitive-data/:/etc/sensitive-data \
        -v ${dir}/provisioning/nagios-config/:/usr/local/nagios/etc \
        -v ${dir}/provisioning/nagios-plugins/:/usr/local/nagios/libexec-custom \
        -v ${dir}/provisioning/nagvis-config/:/usr/local/nagvis/etc \
        $1
	#rayburgemeestre/nagiosnagvis:v2
else
    docker run $* -p 7000:80 -t -i \
        -v ${dir}/rrd-data/:/usr/local/nagiosgraph/var/rrd \
        -v ${dir}/sensitive-data/:/etc/sensitive-data \
	$1
        #rayburgemeestre/nagiosnagvis:v2

fi

