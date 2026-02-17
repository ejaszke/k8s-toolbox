FROM alpine:3.20

WORKDIR /app

COPY . .

CMD ["sh", "-c", "echo 'k8s repo container ready'; ls -la /app"]
