FROM nginx:v1.21.6

COPY nginx.conf /etc/nginx/nginx.conf
COPY templates /etc/nginx/templates