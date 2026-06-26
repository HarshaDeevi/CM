FROM busybox:latest

WORKDIR /www

COPY app.sh /app.sh

RUN chmod +x /app.sh

EXPOSE 8080

CMD ["/app.sh"]
