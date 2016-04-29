FROM php:5-fpm
MAINTAINER Wenbin Wang <wenbin1989@gmail.com>

# install nginx
ENV NGINX_VERSION 1.9.15-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        runit \
        nginx=${NGINX_VERSION} \
        nginx-module-xslt \
        nginx-module-geoip \
        nginx-module-image-filter \
        nginx-module-perl \
        nginx-module-njs \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# let nginx run with user www-data
RUN sed -i -e "s/user\s*nginx;/user  www-data;/" /etc/nginx/nginx.conf

# only allow 127.0.0.1 to connect with php-fpm
RUN echo "listen.allowed_clients = 127.0.0.1" >> /usr/local/etc/php-fpm.d/zz-docker.conf

COPY service /etc/service

# ensure www-data has access to file from volume if the volume is mapped as uid 1000
RUN usermod -u 1000 www-data

EXPOSE 80 443

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]

