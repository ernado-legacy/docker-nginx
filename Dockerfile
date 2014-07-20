FROM ubuntu:latest

MAINTAINER Alexandr Razumov ernado@ya.ru

# base for nginx spdy
RUN apt-get update -qq
RUN apt-get install wget make build-essential zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev zlib1g-dev libpcre3 libpcre3-dev -qqy
RUN apt-get install ca-certificates unzip git -qqy

ENV NPS_VERSION 1.8.31.4
RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
RUN unzip release-${NPS_VERSION}-beta.zip
RUN cd /ngx_pagespeed* && wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && tar -xzvf ${NPS_VERSION}.tar.gz

# tcp proxy module
RUN git clone https://github.com/yaoweibin/nginx_tcp_proxy_module.git

WORKDIR /
ENV NGINX_VER 1.7.3
RUN wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz -nv
RUN tar -xf nginx-$NGINX_VER.tar.gz && rm nginx-$NGINX_VER.tar.gz
RUN cd nginx-$NGINX_VER && patch -p1 < /nginx_tcp_proxy_module/tcp.patch
RUN cd nginx-$NGINX_VER && ./configure --add-module=/ngx_pagespeed-release-${NPS_VERSION}-beta --with-http_spdy_module --with-http_ssl_module --add-module=/nginx_tcp_proxy_module && make -j $(nproc) -s && make install
RUN mkdir /sites-enabled/
RUN mkdir -p /var/ngx_pagespeed_cache
VOLUME /sites-enabled/
ADD nginx.conf /usr/local/nginx/conf/nginx.conf
RUN mkdir -p /var/nginx/tmp
RUN chmod 777 /var/nginx/tmp

ENTRYPOINT /usr/local/nginx/sbin/nginx
