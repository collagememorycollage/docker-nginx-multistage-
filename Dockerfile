FROM alpine:latest AS base-build-nginx
RUN set -e && \
    apk add --no-cache build-base pcre-dev zlib-dev perl linux-headers && \
    mkdir -p /src && \
    cd /src && \
    mkdir -p /src/openssl-4.0.1 && \
    mkdir -p /src/nginx-1.31.1 && \
    wget https://github.com/openssl/openssl/releases/download/openssl-4.0.1/openssl-4.0.1.tar.gz && \
    tar -xzf openssl-4.0.1.tar.gz -C /src/openssl-4.0.1 --strip-components=1 && \
    wget https://nginx.org/download/nginx-1.31.1.tar.gz && \
    tar -xzf nginx-1.31.1.tar.gz -C /src/nginx-1.31.1 --strip-components=1 && \
    cd /src/nginx-1.31.1 && \
    ./configure --prefix=/var/www \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --conf-path=/etc/nginx/nginx.conf \
                --pid-path=/run/nginx/nginx.pid \
                --lock-path=/run/nginx/nginx.lock \
                --sbin-path=/usr/bin/nginx \
                --builddir=/src/nginx-1.31.1/build \
                --with-http_v2_module \
                --with-http_realip_module \
                --with-http_auth_request_module \
                --with-http_ssl_module \
                --with-openssl=/src/openssl-4.0.1 && \
                # --with-opessl-opt=enable-tls1_3 && \
    make

FROM alpine:latest
COPY --from=base-build-nginx /src/nginx-1.31.1/build /src/build
COPY --from=base-build-nginx /src/nginx-1.31.1/conf /src/build/conf
COPY --from=base-build-nginx /src/nginx-1.31.1/html /src/build/html

RUN set -e && \
    apk add --no-cache pcre && \
    addgroup -S nginx && adduser -D -S -G nginx nginx && \
    mkdir -p /var/www && \
    cp -r /src/build/html /var/www/ && \
    cp /src/build/nginx /usr/bin/nginx && \
    mkdir -p /etc/nginx && \
    cp /src/build/conf/* /etc/nginx && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /var/log/nginx && \
    mkdir -p /run/nginx && \
    chown -R nginx:nginx /var/www/html && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /run/nginx && \
    rm -r /src && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]




    


