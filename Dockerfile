# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-net_backup"
LABEL REPO="https://github.com/FragmentedPacket/net_backup"

ENV PROJPATH=/go/src/github.com/FragmentedPacket/net_backup

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/FragmentedPacket/net_backup
WORKDIR /go/src/github.com/FragmentedPacket/net_backup

RUN make build-alpine

# Final Stage
FROM fragmentedpacket

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/FragmentedPacket/net_backup"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/net_backup/bin

WORKDIR /opt/net_backup/bin

COPY --from=build-stage /go/src/github.com/FragmentedPacket/net_backup/bin/net_backup /opt/net_backup/bin/
RUN chmod +x /opt/net_backup/bin/net_backup

# Create appuser
RUN adduser -D -g '' net_backup
USER net_backup

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/net_backup/bin/net_backup"]
