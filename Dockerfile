FROM ubuntu:16.04
RUN apt update && apt install -y git curl wget ca-certificates software-properties-common build-essential
ENV DEBIAN_FRONTEND noninteractive
ARG PHPVER=5.6
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt update && \
    apt install -y php$PHPVER php$PHPVER-mbstring php$PHPVER-mcrypt php$PHPVER-mysql php$PHPVER-xml php$PHPVER-mysql php$PHPVER-intl php$PHPVER-fpm \
    nginx libgmp3-dev libmysqlclient-dev libcurl4-openssl-dev libidn11-dev librtmp-dev libldap2-dev libkrb5-dev comerr-dev \
    php$PHPVER-cli libssl-dev php5.6-curl patch

# Nginx config
RUN find /etc/nginx/ && rm /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN mkdir -p /var/log/fpm
RUN mkdir -p /var/www

# PHP config
RUN sed -i -e "s/;\?date.timezone\s*=\s*.*/date.timezone = UTC/g" /etc/php/5.6/fpm/php.ini
RUN sed -i -re "s/.*chdir .*/chdir = \/var\/www/g" /etc/php/$PHPVER/fpm/pool.d/www.conf
RUN sed -i -re "s/.*catch_workers_output .*/catch_workers_output = yes/g" /etc/php/$PHPVER/fpm/pool.d/www.conf
RUN sed -i -re "s/.*pm\.max_children .*/pm.max_children = 100/g" /etc/php/$PHPVER/fpm/pool.d/www.conf
RUN sed -i -re "s/.cd *error_log .*/error_log = \/var\/log\/fpm\/php$PHPVER-fpm.log/g" /etc/php/$PHPVER/fpm/php-fpm.conf
RUN sed -i -re "s/.*rlimit_files .*/rlimit_files = 10240/g" /etc/php/$PHPVER/fpm/php-fpm.conf
RUN sed -i -re "s/.*rlimit_files .*/rlimit_files = 10240/g" /etc/php/$PHPVER/fpm/pool.d/www.conf
RUN sed -i -re "s/.*pm\.max_spare_servers .*/pm.max_spare_servers = 10/g" /etc/php/$PHPVER/fpm/pool.d/www.conf
RUN sed -i -re "s/.*pm\.start_servers .*/pm.start_servers = 5/g" /etc/php/$PHPVER/fpm/pool.d/www.conf
RUN sed -i -re "s/.*max_execution_time .*/max_execution_time = 300/g" /etc/php/$PHPVER/fpm/php.ini
RUN sed -i -re "s/.*clear_env =.*/clear_env = no/g" /etc/php/$PHPVER/fpm/pool.d/www.conf

# Define default command.
CMD /mk-env && service php$PHPVER-fpm start && nginx

VOLUME /var/www
EXPOSE 80
