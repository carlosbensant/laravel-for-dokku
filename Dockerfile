FROM ubuntu:xenial


MAINTAINER Carlos Bensant <info@spot.com.do>


# Install Dependecies
RUN apt-get update && apt-get upgrade \
  apt-get install -y --force-yes software-properties-common curl && \
  apt-add-repository ppa:ondrej/php -y && \
  apt-get update && \
	apt-get install -y --force-yes php7.2-fpm php7.2-cli php7.2-dev \
    php7.2-pgsql php7.2-sqlite3 php7.2-gd \
    php7.2-curl php7.2-memcached \
    php7.2-imap php7.2-mysql php7.2-mbstring \
    php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap \
    php7.2-intl php7.2-readline \
  	nginx zip supervisor git php7.2-mcrypt


# Enable mcrypt
RUN phpenmod mcrypt


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer


# Install Node/NPM
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
ENV NODE_VER v8.11.3
ENV NVM_DIR "/root/.nvm"
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VER \
    && nvm alias default $NODE_VER \
    && nvm use default \
ENV BASE_NODE_PATH $NVM_DIR/versions/node
ENV NODE_PATH $BASE_NODE_PATH/$NODE_VER/lib/node_modules
ENV PATH $BASE_NODE_PATH/$NODE_VER/bin:$PATH


# Configurations
RUN mkdir /run/php
COPY nginx/default /etc/nginx/sites-available
COPY supervisord /etc/supervisor/conf.d
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/max_execution_time = .*/max_execution_time = 300/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/fpm/php.ini


# Add our init script
ADD run.sh /run.sh
RUN chmod 755 /run.sh


RUN mkdir /app
WORKDIR /app
RUN mkdir /app/public && touch /app/public/index.php && echo '<?php phpinfo();?>' > /app/public/index.php

EXPOSE 80

CMD ["/run.sh"]
