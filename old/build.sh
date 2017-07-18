#!/bin/sh

typeset dir=$(pwd)

sudo chown -R 1000:50 ${dir}/provisioning
sudo chmod -R     755 ${dir}/provisioning

docker build -t rayburgemeestre/nagiosnagvis:v2 .

echo "update docker hub with: docker push rayburgemeestre/nagiosnagvis:v2"
