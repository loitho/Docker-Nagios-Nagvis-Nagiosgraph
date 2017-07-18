FROM ubuntu:14.04

# big thanks to Ray Burgemeestre
MAINTAINER Loitho


ENV	DEBIAN_FRONTEND=noninteractive

ENV	nagios=nagios-4.1.1
ENV	livestatusversion=1.2.6p16
ENV	nagiosplugins=nagios-plugins-2.1.1
ENV	nagvis=nagvis-1.8.5
ENV	nagiosgraphversion=1.5.2
ENV	nrpeversion=nrpe-2.15



EXPOSE 80
EXPOSE 5666



RUN	apt-get update && \
    ### apache and php and other prerequisites for nagios\
    #apt-get install -y build-essential libgd2-xpm-dev openssl libssl-dev xinetd apache2-utils unzip

#NAGIOS
    #apt-get install wget
     #build-essential apache2 php5-gd
     #libgd2-xpm
     #libgd2-xpm-dev libapache2-mod-
     #php5


#NAGIOS GRAPH
#	apt-get install libcgi-pm-perl librrds-perl
#      	apt-get install libgd-gd2-perl libnagios-object-perl

     apt-get install -y --no-install-recommends \

		#build-essential \
		gcc	\
		apache2 \
		php5 	\
	       	php5-gd \
	       	php5-sqlite	\
	       	apache2-utils 	\
		xinetd 		\
		supervisor \
		#&& \

	
#	apt-get install -y --no-install-recommends \
		rsync \
		nano \
		wget \
		telnet \
		make \
		unzip \
		#&& \

### nagios plugins ssl support \
	#apt-get install -y --no-install-recommends \
		openssl    			   \
		libssl-dev  			   \
		ca-certificates			   \
		#&& \
		       ### nagiosgraph dependencies.. \
# 	apt-get install -y --no-install-recommends \
		libcgi-pm-perl \
		librrds-perl \
		libgd-gd2-perl \
		libnagios-object-perl \

# Packages pour mklive
		build-essential dpatch dnsutils fping smbclient \
		git-buildpackage libboost-all-dev \
		libcloog-ppl1 libcurl4-openssl-dev  libevent-dev \
		libgd2-xpm-dev libglib2.0-dev libgnutls-dev \
		libldap2-dev libltdl-dev libmcrypt-dev \
		libmysqlclient15-dev libpango1.0-dev \
		libperl-dev libreadline-dev libssl-dev libxml2-dev patch \
		python-dev python-setuptools uuid-dev snmp apache2-threaded-dev \
		libncurses5-dev dietlibc-dev  libpcap-dev  gettext  libgsf-1-dev \
		libradiusclient-ng-dev \

		aptitude 	      && \


		apt-get clean 	      && \
		apt-get autoclean     && \
		rm -rf /var/lib/apt/lists/* \
		       /tmp/* 		    \
		       /var/tmp/* 	    && \

### enable apache modules.. \
    	a2enmod rewrite && \
    	a2enmod cgi && \
    \
    ### add nagios (and www-data) user and make them part of nagioscmd group \
    	useradd -ms /bin/bash nagios && \
    	groupadd nagcmd && \
    	usermod -a -G nagcmd nagios && \
    	usermod -a -G nagcmd www-data



#WORKDIR /usr/local/src
WORKDIR /usr/local/src/${nagios}
RUN	wget https://assets.nagios.com/downloads/nagioscore/releases/${nagios}.tar.gz && \
    	tar -zxvf ${nagios}.tar.gz -C ../					      && \
	./configure --with-command-group=nagcmd 				      && \
    	make all    								      && \
    	make install 								      && \
    	make install-init 							      && \
    	make install-config 							      && \
    	make install-commandmode 						      && \
    	/usr/bin/install -c					\
			 -m 644					\
			 sample-config/httpd.conf		\
			 /etc/apache2/sites-enabled/nagios.conf && \
    	echo -n admin | htpasswd -i -c /usr/local/nagios/etc/htpasswd.users nagiosadmin && \

	rm -rf /usr/local/src/${nagios}


WORKDIR /usr/local/src/check-mk-raw-${livestatusversion}.cre
RUN	wget https://mathias-kettner.de/support/${livestatusversion}/check-mk-raw-${livestatusversion}.cre.tar.gz && \
	tar -zxvf check-mk-raw-${livestatusversion}.cre.tar.gz -C ../ && \
	rm -rf check-mk-raw-${livestatusversion}.cre.tar.gz    	      && \
	./configure --with-nagios4 	&& \
	make 	    			&& \
### specifically make mk-livestatus package /again/ with the --with-nagios4 flag,
### by default it's build for nagios3 which doesn't work.. \
### /usr/local/lib/mk-livestatus/livestatus.o /usr/local/nagios/var/rw/live

        cd ./packages/mk-livestatus/mk-livestatus-${livestatusversion} && \
    	make clean && \
	./configure --with-nagios4 && \
    	make && \
    	make install && \

       rm -rf /usr/local/src/check-mk-raw-${livestatusversion}.cre



WORKDIR /usr/local/src/${nagiosplugins}
RUN 	wget http://nagios-plugins.org/download/${nagiosplugins}.tar.gz && \
	tar -zxvf ${nagiosplugins}.tar.gz -C ../			&& \

	./configure --with-nagios-user=nagios				   \
		    --with-nagios-group=nagios 				   \
		    --with-openssl					&& \
    	make 								&& \
    	make install 							&& \

	rm -rf /usr/local/src/${nagiosplugins}


WORKDIR /usr/local/src/${nagvis}
RUN	wget http://www.nagvis.org/share/${nagvis}.tar.gz	&& \
   	tar -zxvf ${nagvis}.tar.gz -C ../			&& \

	./install.sh -n /usr/local/nagios			   \
		     -p /usr/local/nagvis			   \
		     -l "unix:/usr/local/nagios/var/rw/live"	   \
		     -b mklivestatus				   \
		     -u www-data				   \
		     -g www-data				   \
		     -w /etc/apache2/conf-enabled		   \
		     -a y					   \
		     -F -q 				        && \

	rm -rf /usr/local/src/${nagvis}				&& \

### Fix nagvis apache2.4 vhost
    	printf "%s\n" "<Directory \"/usr/local/nagvis/share\">" \
	       	      "  Require all granted"			\
		      "</Directory>"				\
	>> /etc/apache2/conf-enabled/nagvis.conf


WORKDIR /usr/local/src/nagiosgraph-${nagiosgraphversion}
RUN    	wget http://downloads.sourceforge.net/project/nagiosgraph/nagiosgraph/${nagiosgraphversion}/nagiosgraph-${nagiosgraphversion}.tar.gz && \
	tar -zxvf nagiosgraph-${nagiosgraphversion}.tar.gz -C ../ && \

	./install.pl --check-prereq				  && \
    	NG_PREFIX=/usr/local/nagiosgraph			     \
	NG_WWW_DIR=/usr/local/nagios/share 			     \
	./install.pl --prefix=/usr/local/nagiosgraph 		  && \

	rm -rf /usr/local/src/nagiosgraph-${nagiosgraphversion}	  && \

### Fix nagiosgraph vhost
    	cp -prv /usr/local/nagiosgraph/etc/nagiosgraph-apache.conf /etc/apache2/sites-enabled/ && \
    	printf "%s\n" "<Directory \"/usr/local/nagiosgraph/cgi/\">"	\
    	       	      "  Require all granted"				\
    		      "</Directory>"					\
	>> /etc/apache2/sites-enabled/nagiosgraph-apache.conf		&& \

### fix the perfdata log location in nagiosgraph.conf \
    	sed -i 's/\/tmp\/perfdata.log/\/usr\/local\/nagios\/var\/perfdata.log/' /usr/local/nagiosgraph/etc/nagiosgraph.conf


WORKDIR /usr/local/src/${nrpeversion}
RUN	wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/${nrpeversion}/${nrpeversion}.tar.gz && \
   	tar -zxvf ${nrpeversion}.tar.gz -C ../			&& \

	./configure --enable-command-args  			\
		    --with-nagios-user=nagios			\
		    --with-nagios-group=nagios			\
		    --with-ssl=/usr/bin/openssl			\
		    --with-ssl-lib=/usr/lib/x86_64-linux-gnu	&& \

	make all    						&& \
	make install-xinetd					&& \
	make install-daemon-config				&& \
        make install						&& \

	#sed -i
	rm -rf /usr/local/src/${nrpeversion}


    ### remplacer avec service start
# RUN	printf "%s\n" "/usr/sbin/apache2ctl start" \
# 		      "service xinetd start" \
# 		      ## Dernier service à lancer, il est bloquant ##
# 		      "/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg" \
# 	>> /usr/bin/start-apache-and-nagios.sh


WORKDIR	/root

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


#ADD provisioning/nagios-ssh                         /home/nagios/.ssh
#ADD provisioning/system-scripts/slack_notification  /usr/bin/slack_notification
#ADD provisioning/system-scripts/slack_nagios.pl     /usr/bin/slack_nagios.pl
COPY provisioning/supervisord.conf	/etc/supervisor/conf.d/supervisord.conf
COPY provisioning/nagios-config		/usr/local/nagios/etc
COPY provisioning/nagvis-config		/usr/local/nagvis/etc

COPY provisioning/nagios-plugins	/usr/local/nagios/libexec-custom

COPY provisioning/index.php		/var/www/html/index.php

COPY provisioning/nagvis-config		/usr/local/nagvis/etc
COPY provisioning/nagvis-config/shapes	/usr/local/nagvis/share/userfiles/images/

RUN \
	
	chown nagios:nagcmd /usr/local/nagios/etc -R	&& \
	chown www-data:www-data /usr/local/nagvis -R	&& \
	rm /var/www/html/index.html		  	&& \
	ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime



#####
##
## IL FAUT TELECHARGER LE PLUGING CHECK_MEM
#wget https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl
# mv check_mem.pl check_mem
# chmod +x check_mem 
##
#####
#ENTRYPOINT ["/bin/bash", "/usr/bin/start-apache-and-nagios.sh"]
