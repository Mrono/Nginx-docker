FROM phusion/baseimage:0.9.15

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN (usermod -u 1000 www-data)
RUN (groupmod -g 1000 www-data)
#may not need to change file perms
#RUN (find / -uid 1000 -exec chown -h 5000 '{}' \+)

# Nginx-PHP Installation
RUN apt-get update
RUN apt-get install -y  python-software-properties
#RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y --force-yes php5-cli php5-fpm php5-mysql php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap php5-xdebug nginx

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
RUN sed -i "s/;pm.max_children = 5/pm.max_children = 49/" /etc/php5/fpm/pool.d/www.conf
 
RUN mkdir -p /var/www &&\
  chown -R www-data:www-data /var/www &&\
  chmod -R 777 /var/www
ADD Dockerbuild/default   /etc/nginx/sites-available/default
RUN mkdir           /etc/service/nginx
ADD Dockerbuild/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir           /etc/service/phpfpm
ADD Dockerbuild/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run
ADD Dockerbuild/20-xdebug.ini	/etc/php5/fpm/conf.d/20-xdebug.ini

VOLUME ["/var/www"]

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN php5enmod mcrypt

CMD ["/sbin/my_init"]
