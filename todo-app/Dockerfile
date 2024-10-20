####### Builder Stage #######

FROM golang:1.20-alpine as builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o bin .


######## Runner Stage ########

FROM alpine:latest as runner

WORKDIR /app

COPY --from=builder /app/bin /app/bin
COPY --from=builder /app/templates /app/templates

EXPOSE 8080

CMD ["/app/bin"]
