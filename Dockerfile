# http://nginx.org/download/nginx-1.5.10.tar.gz
FROM ubuntu:latest

MAINTAINER Alexandr Razumov ernado@ya.ru

# base for nginx spdy
RUN sed -i 's/archive.ubuntu.com/mirror.yandex.ru/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install wget make build-essential zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev zlib1g-dev libpcre3 libpcre3-dev -y
RUN apt-get install ca-certificates unzip -y

RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.2-beta.zip
RUN unzip v1.8.31.2-beta.zip
WORKDIR /ngx_pagespeed-1.8.31.2-beta
RUN wget https://dl.google.com/dl/page-speed/psol/1.8.31.2.tar.gz
RUN tar -xzvf 1.8.31.2.tar.gz

WORKDIR /
ENV NGINX_VER 1.6.0
RUN wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz -nv && tar -xf nginx-$NGINX_VER.tar.gz && rm nginx-$NGINX_VER.tar.gz
RUN cd nginx-$NGINX_VER && ./configure --add-module=/ngx_pagespeed-1.8.31.2-beta --with-http_spdy_module --with-http_ssl_module && make -j8 -s && make install
RUN mkdir /sites-enabled/
RUN mkdir -p /var/ngx_pagespeed_cache
VOLUME /sites-enabled/
ADD nginx.conf /usr/local/nginx/conf/nginx.conf

ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
