FROM golang:1.20-alpine

WORKDIR /app

COPY go.mod .

COPY . .

RUN go get 

RUN go build -o bin .

EXPOSE 8080

CMD ["/app/bin"]
