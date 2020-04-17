FROM alpine:latest as base

RUN apk add --update alpine-sdk
RUN git clone --depth=1 --recursive https://github.com/google/ngx_brotli.git 
RUN wget https://nginx.org/download/nginx-1.17.9.tar.gz && tar -xvf nginx-1.17.9.tar.gz
RUN apk add pcre-dev zlib-dev
RUN cd  nginx-1.17.9 && ./configure \
    --with-cc-opt="-O3 -static -static-libgcc" \
    --with-ld-opt="-static" \
    --prefix=/opt/nginx \
    --with-http_auth_request_module \
    --without-http_gzip_module \
    --add-module=/ngx_brotli && \
    make && make install

# Logs to stdout / stderr
# RUN ln -sf /dev/stdout /opt/nginx/logs/access.log && ln -sf /dev/stderr /opt/nginx/logs/error.log

# Run ldd /opt/nginx/sbin/nginx to see dependancies
# See also: https://github.com/sdenel/docker-nginx-file-listing/blob/master/Dockerfile
RUN mkdir -p /opt/var/cache/nginx && \
    cp -a --parents /lib/ld-musl-x86_64.so.* /opt

FROM gcr.io/distroless/base
MAINTAINER Simon DENEL, simondenel1@gmail.com

COPY --from=base /opt/nginx /opt/nginx
COPY --from=base /opt/lib /lib
EXPOSE 80

COPY nginx.default.conf /opt/nginx/conf/nginx.conf

ENTRYPOINT ["/opt/nginx/sbin/nginx", "-g", "daemon off; error_log stderr info;"]