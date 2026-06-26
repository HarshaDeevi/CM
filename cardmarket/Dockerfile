FROM busybox:latest

WORKDIR /www

COPY index.html .

EXPOSE 8080

CMD httpd -f -p 8080 -h /www
