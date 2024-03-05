FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y mysql-client s3cmd ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR "/app"
COPY . .

RUN chmod +x ./script.sh

CMD ["./script.sh"]
