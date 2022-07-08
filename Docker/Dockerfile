FROM alpine:latest
LABEL maintainer="Korovin's Docker"
RUN apk update && apk add nginx
COPY index.html /var/www/localhost/htdocs
COPY default.conf /etc/nginx/httpt.d
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
