# docker-nginx-distroless-with-brotli 

A distroless docker image of nginx:
* compiled with:
    * ngx_brotli (https://github.com/google/ngx_brotli)
    * http_auth_request_module
* Provided nginx.conf is serving any static content in /mnt/data/, with autoindex on.
