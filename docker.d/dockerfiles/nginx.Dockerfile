FROM nginx:latest

CMD /bin/bash -c "envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && envsubst < /etc/nginx/conf.d/vhosts.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"