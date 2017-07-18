#!/bin/bash
docker build -t loitho/nag-ios-vis-graph .
docker rm nagios
docker run --name nagios -it -p 88:80 loitho/nag-ios-vis-graph
