#!/bin/bash

NGINX_VER=1.13.8

apt-get update && apt-get install -y git build-essential libtool automake autoconf zlib1g-dev \
libpcre3-dev libgd-dev libssl-dev libxslt1-dev libxml2-dev libgeoip-dev \
libgoogle-perftools-dev libperl-dev libpam0g-dev

rm -rf /usr/local/src/*
cd /usr/local/src/nginx/ || exit

git clone https://github.com/FRiCKLE/ngx_cache_purge.git
git clone https://github.com/openresty/memc-nginx-module.git
git clone https://github.com/simpl/ngx_devel_kit.git
git clone https://github.com/openresty/headers-more-nginx-module.git
git clone https://github.com/openresty/echo-nginx-module.git
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
git clone https://github.com/openresty/redis2-nginx-module.git
git clone https://github.com/openresty/srcache-nginx-module.git
git clone https://github.com/openresty/set-misc-nginx-module.git
git clone https://github.com/FRiCKLE/ngx_coolkit.git
git clone https://github.com/FRiCKLE/ngx_slowfs_cache.git
git clone https://github.com/sto/ngx_http_auth_pam_module.git

wget https://people.freebsd.org/~osa/ngx_http_redis-0.3.8.tar.gz
tar -zxf ngx_http_redis-0.3.8.tar.gz
mv ngx_http_redis-0.3.8 ngx_http_redis

git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli
git submodule update --init --recursive

cd /usr/local/src/nginx/ || exit

git clone https://github.com/openssl/openssl.git
cd openssl
git checkout tls1.3-draft-18

cd /usr/local/src/nginx/ || exit

bash <(curl -f -L -sS https://ngxpagespeed.com/install) --ngx-pagespeed-version latest-beta -b /usr/local/src

cd /usr/local/src/nginx/ || exit

wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz
tar -xzvf nginx-${NGINX_VER}.tar.gz
mv nginx-${NGINX_VER} nginx

cd /usr/local/src/nginx/ || exit

wget https://raw.githubusercontent.com/cujanovic/nginx-dynamic-tls-records-patch/master/nginx__dynamic_tls_records_1.13.0%2B.patch
patch -p1 < nginx__dynamic_tls_records_1.13*.patch


./configure \
 --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' \
 --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
 --prefix=/etc/nginx \
 --sbin-path=/usr/sbin/nginx \
 --conf-path=/etc/nginx/nginx.conf \
 --error-log-path=/var/log/nginx/error.log \
 --http-log-path=/var/log/nginx/access.log \
 --lock-path=/var/lock/nginx.lock \
 --pid-path=/var/run/nginx.pid \
 --http-client-body-temp-path=/var/lib/nginx/body \
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
 --http-proxy-temp-path=/var/lib/nginx/proxy \
 --http-scgi-temp-path=/var/lib/nginx/scgi \
 --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
 --user=nginx \
 --group=nginx \
 --with-pcre-jit  \
 --with-http_ssl_module  \
 --with-http_stub_status_module  \
 --with-http_realip_module  \
 --with-http_auth_request_module  \
 --with-http_addition_module  \
 --with-http_geoip_module  \
 --with-http_gzip_static_module  \
 --with-http_image_filter_module  \
 --with-http_v2_module  \
 --with-http_sub_module  \
 --with-http_xslt_module  \
 --with-threads  \
 --add-module=/usr/local/src/ngx_cache_purge  \
 --add-module=/usr/local/src/memc-nginx-module \
 --add-module=/usr/local/src/ngx_devel_kit  \
 --add-module=/usr/local/src/headers-more-nginx-module \
 --add-module=/usr/local/src/echo-nginx-module  \
 --add-module=/usr/local/src/ngx_http_substitutions_filter_module  \
 --add-module=/usr/local/src/redis2-nginx-module  \
 --add-module=/usr/local/src/srcache-nginx-module  \
 --add-module=/usr/local/src/set-misc-nginx-module  \
 --add-module=/usr/local/src/ngx_http_redis   \
 --add-module=/usr/local/src/incubator-pagespeed-ngx-latest-beta  \
 --add-module=/usr/local/src/ngx_brotli  \
 --add-module=/usr/local/src/ngx_http_auth_pam_module \
 --with-openssl=/usr/local/src/openssl \
 --with-openssl-opt=enable-tls1_3
 
make -j $(nproc)
make install

sudo systemctl unmask sw-nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo apt-mark hold sw-nginx


