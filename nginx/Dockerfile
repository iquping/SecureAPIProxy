FROM nginx:latest
RUN apt-get update && apt-get install -y libnginx-mod-http-lua luarocks
RUN luarocks install lua-resty-redis
COPY nginx.conf /etc/nginx/nginx.conf
COPY lua/check_token.lua /etc/nginx/lua/check_token.lua
