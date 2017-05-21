FROM phusion/baseimage
LABEL version="0.0.2"


# LOCALIZATION ================================================================

# ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8



# ROOT SETUP ==================================================================

# setup
ENV HOME /root
ENV PATH "$PATH:/usr/local/bin"
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]



# INSTALLATION ================================================================

# NGINX + PHP7 installation
RUN DEBIAN_FRONTEND="noninteractive" apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade
RUN DEBIAN_FRONTEND="noninteractive" apt-get update --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.0
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.0-fpm php7.0-common php7.0-cli php7.0-mysqlnd php7.0-mcrypt php7.0-curl php7.0-bcmath php7.0-mbstring php7.0-soap php7.0-xml php7.0-zip php7.0-json php7.0-imap php-xdebug php-pgsql
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.0-dev php-pear libsasl2-dev

# NGINX (full) installation
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx-full

# NODEJS installation
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nodejs
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y npm

# GIT + NANO + MC installation
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git nano mc

# MONGODB installation
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN apt-get install -y --no-install-recommends software-properties-common
RUN echo "deb http://repo.mongodb.org/apt/ubuntu $(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN apt-get update && apt-get install -y mongodb-org

# PHP COMPOSER installation
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer



# SETUP =======================================================================

# Create the OpenSSL directories and links
RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

# Add build script (also set timezone to Europe/Berlin)
RUN mkdir -p /root/setup
ADD build/setup.sh /root/setup/setup.sh
RUN chmod +x /root/setup/setup.sh
RUN (cd /root/setup/; /root/setup/setup.sh)

# Copy configuration files from repository to the image
ADD build/nginx.conf /etc/nginx/sites-available/default
ADD build/.bashrc /root/.bashrc

# Create the MongoDB data directory
RUN mkdir -p /data/db

# Add MongoDB PHP driver (legacy)
RUN pecl config-set php_ini /etc/php/7.0/fpm/php.ini
RUN pecl install mongodb

# Setting up the MongoDB ini files
RUN echo "extension=mongodb.so" > /etc/php/7.0/fpm/conf.d/20-mongodb.ini && \
    echo "extension=mongodb.so" > /etc/php/7.0/cli/conf.d/20-mongodb.ini && \
    echo "extension=mongodb.so" > /etc/php/7.0/mods-available/mongodb.ini

# Add PHP Library for MongoDB (PHPLIB)
RUN /usr/local/bin/composer require mongodb/mongodb

# Disable services start
RUN update-rc.d -f apache2 remove
RUN update-rc.d -f nginx remove
RUN update-rc.d -f php7.0-fpm remove

# Add startup scripts for nginx
ADD build/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# Add startup scripts for php7.0-fpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/phpfpm/run

# Add startup scripts for mongodb
ADD build/mongod.sh /etc/service/mongod/run
RUN chmod +x /etc/service/mongod/run

# Set WWW public folder
RUN mkdir -p /var/www/public
ADD build/index.php /var/www/public/index.php
RUN chown -R www-data:www-data /var/www
RUN chmod 755 /var/www

# Set terminal environment
ENV TERM=xterm



# PORTS =======================================================================

# port and settings
EXPOSE 80 9000 27017



# FINALIZATION ================================================================

# cleanup apt and lists
RUN apt-get clean
RUN apt-get autoclean
