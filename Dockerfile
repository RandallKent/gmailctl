FROM golang:1.23-alpine

RUN apk --no-cache apk update && apk --no-cache upgrade

WORKDIR /usr/src/gmailctl

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o /usr/local/bin ./...

# Build the docker container:
# docker build -t randallkent/gmailctl -t randallkent/gmailctl:latest .

# Setup function in bash_profile to run this docker container and not keep the container after it exits 
# Exposes port to complete auth to generate token.json
# Command example: `gmailctl init` from host machine will run in docker 
#
# gmailctl(){
# 	## Be sure to create the directory ~/.gmailctl
# 	docker run --rm -it -v "$HOME/.gmailctl:/root/.gmailctl" -p 33421:33421 -h 0.0.0.0 gmailctl $@
# }

# Can also run interactively, exposing ports to generate token.json
# Be sure to create the directory ~/.gmailctl
# docker run -it -v "$HOME/.gmailctl:/root/.gmailctl" -p 33421:33421 -h 0.0.0.0 --entrypoint bash gmailctl

ENTRYPOINT ["gmailctl"]