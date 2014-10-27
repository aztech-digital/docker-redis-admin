FROM ubuntu:latest

MAINTAINER Thibaud Fabre

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y redis-server php5 git curl supervisor openssh-server
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin
RUN mkdir -p /var/www/
RUN mkdir -p /var/log/apache
RUN git clone https://github.com/ErikDubbelboer/phpRedisAdmin.git /var/www/redis-admin/
RUN cd /var/www/redis-admin && composer update

RUN sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
    sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
    sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
    sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

RUN rm /etc/apache2/sites-enabled/*.conf
ADD redis-admin.conf /etc/apache2/sites-available/redis-admin.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN a2ensite redis-admin

EXPOSE 22 80 6379

CMD [ "/usr/bin/supervisord" ]
#CMD [ "/bin/bash" ]
