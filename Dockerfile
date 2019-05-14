# Build Box
FROM golang:1.12 AS build

RUN mkdir -p /home/main
WORKDIR /home/main

# Lint
ENV GO111MODULE=auto
RUN go get -u golang.org/x/lint/golint

# Deps
ENV GO111MODULE=on
COPY go.mod .
COPY go.sum .

RUN go mod download

# ENVS
ARG AWS_DB_REGION
ARG AWS_DB_ENDPOINT
ARG AWS_DB_TABLE
ARG AUTH_HEADER
ARG AUTH_PREFIX

COPY . .
RUN golint -set_exit_status ./...
RUN go test -short ./...
RUN go test -race -short ./...

# Build App
ARG build
ARG version
ARG serviceName
RUN CGO_ENABLED=0 go build -ldflags="s -w -X main.Version=${version} -X main.Build=${build}" -o ${serviceName}
RUN cp ${serviceName} /

# Run Box
FROM alpine
ARG serviceName
RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN apk add --update tzdata
RUN apk add curl
RUN rm -rf /var/cache/apk