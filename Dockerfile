FROM golang:1.17 AS builder

ENV SOURCE_PATH ${GOPATH}/src/0xacab.org/leap/obfsvpn
WORKDIR ${SOURCE_PATH}
RUN pwd
RUN git clone https://0xacab.org/leap/obfsvpn.git . && \
    cd server && make build && cp server test_data/obfs4.json /


FROM alpine:3.14.1

LABEL maintainer="Alexander Litvinenko <array.shift@yahoo.com>"

ENV APP_NAME Dockovpn
ENV APP_INSTALL_PATH /opt/${APP_NAME}
ENV APP_PERSIST_DIR /opt/${APP_NAME}_data

WORKDIR ${APP_INSTALL_PATH}

COPY --from=builder /server /usr/local/bin/obfsvpn-server
COPY --from=builder /obfs4.json /opt/obfs4.json

COPY scripts .
COPY config ./config
COPY VERSION ./config

RUN apk add --no-cache openvpn easy-rsa bash netcat-openbsd zip dumb-init && \
    mkdir -p ${APP_PERSIST_DIR} && \
    cd ${APP_PERSIST_DIR} && \
    /usr/share/easy-rsa/easyrsa init-pki && \
    /usr/share/easy-rsa/easyrsa gen-dh && \
    # DH parameters of size 2048 created at /usr/share/easy-rsa/pki/dh.pem
    # Copy DH file
    cp pki/dh.pem /etc/openvpn && \
    # Copy FROM ./scripts/server/conf TO /etc/openvpn/server.conf in DockerFile
    cd ${APP_INSTALL_PATH} && \
    cp config/server.conf /etc/openvpn/server.conf

EXPOSE 4430/tcp

VOLUME [ "/opt/Dockovpn_data" ]

ENTRYPOINT [ "dumb-init", "./start.sh" ]
CMD [ "" ]
