FROM debian:trixie-slim

ENV TZ=Asia/Bangkok

RUN apt-get update \
  && apt-get install -y --no-install-recommends tzdata openssl ca-certificates bash rclone \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN mkdir -p /etc/docker/my-image/generate-csr-to-gdrive/replaced_conf
COPY generate-csr-script.sh /etc/docker/my-image/generate-csr-to-gdrive/