# Nag-ios-vis-graph : Docker image to deploy a Nagios Nagiosgraph Nagvis monitoring solution 

## Synopsis

Based on Ryan Burgmester docker image available here : http://blog.cppse.nl/nagios4-nagvis-nagiosgraph-docker

I modified it and improved it in order to have the lastest versions of nagios / nagvis / nagiosgraph and added NRPE.


| Program          | Version   |
| ---------------- |:----------|
| Nagios           | 4.1.1     |
| Nagios-plugins   | 2.1.1     |
| Nagvis           | 1.8.5     |
| Nagiosgraph      | 1.5.2     |
| NRPE             | 2.15      |
| Livestatus       | 1.2.6p16  |



## Installation

### Automatically from docker hub:
to installthe image from the docker hub simply docker run it and it'll get pull automatically : 
* docker run -d -p 80:80 loitho/nag-ios-vis-graph

### Manually from the source code:
You can build the whole docker image from the git folder, simply clone the repository and run the shell script :
* ./run.sh 

### Side note 
if you want to acces the container and add host / modify the configuration run the image 
* docker exec -it *your container* bash

## Accessing servers

To acces the servers just go to 

http://your_server_ip/nagios
* username : nagiosadmin
* password : admin

http://your_server_ip/nagvis
* username : admin
* password : admin


## Some more information

The docker container keeps running thanks to supervisor, that starts apache2, nagios and xinetd (for NRPE) 

## Contributors

If you think I've done something stupid, well ... tell me, use the issue tracker, make a pull request etc ...



