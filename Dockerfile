FROM debian:bookworm
MAINTAINER Peter Mišovic <peter@conexo.cz>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get -yqq install apt-transport-https  ca-certificates \
  vim unzip \
  wget curl git ssh 

RUN \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
  echo "deb https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list && \
apt-get -qq update && apt-get -qqy upgrade

RUN  apt-get -qq update && apt-get install -y \
   libapache2-mod-php8.3 php8.3-cgi \
   php8.3-cli        php8.3-gd      php8.3-common    php8.3-intl    \
   php8.3-mbstring     php8.3-mysql    php8.3-opcache      php8.3-readline       php8.3-xml    php8.3-xsl   \
   php8.3-zip   php8.3-sqlite3 php8.3-curl  php8.3-bcmath \
   apache2 


RUN apt-get update && \
  apt-get -yqq install msmtp

#COPY msmtprc /etc/msmtprc
COPY php.ini /etc/php/8.3/cli/php.ini
COPY php.ini /etc/php/8.3/apache2/php.ini

ADD site.conf /etc/apache2/sites-enabled/000-default.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


RUN mkdir -p /var/www/project && a2enmod vhost_alias ssl  rewrite headers 

#aby apache log sel na stdout dockeru
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

WORKDIR /var/www/html


EXPOSE 80 443

CMD  /usr/sbin/apache2ctl -D FOREGROUND
