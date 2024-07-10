FROM golang:1.16

WORKDIR /app

COPY . .

RUN go mod download
RUN go build -o binlog_to_redis

CMD ["./binlog_to_redis"]
