#!/bin/bash

docker stop nginx
docker rm nginx

docker run -d --name nginx -v /opt/nginx/log:/log  -v /opt/nginx/sites-enabled/:/sites-enabled -v /data/static:/static -v /data/media:/media -p 80:80 -p 443:443 cydev/nginx
