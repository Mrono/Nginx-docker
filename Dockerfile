FROM phusion/baseimage:0.9.15

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Nginx-PHP Installation
RUN apt-get update
RUN apt-get install -y  python-software-properties
#RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y --force-yes php5-cli php5-fpm php5-mysql php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap nginx

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

#RUN apt-get install -y nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
 
RUN mkdir -p /var/www &&\
  chown -R www-data:www-data /var/www
ADD Dockerbuild/default   /etc/nginx/sites-available/default
RUN mkdir           /etc/service/nginx
ADD Dockerbuild/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir           /etc/service/phpfpm
ADD Dockerbuild/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

VOLUME ["/var/www"]

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
