FROM ghcr.io/getalby/hub:v1.10.1 AS builder
RUN apt update; apt install -y --no-install-recommends caddy

FROM debian:12-slim AS final

ENV LD_LIBRARY_PATH=/usr/lib/nwc

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/lib/nwc/libbreez_sdk_bindings.so /usr/lib/nwc/
COPY --from=builder /usr/lib/nwc/libglalby_bindings.so /usr/lib/nwc/
COPY --from=builder /usr/lib/nwc/libldk_node.so /usr/lib/nwc/
COPY --from=builder /bin/main /bin/
COPY --chmod=755 docker_entrypoint.sh /usr/local/bin/
COPY --from=builder /usr/bin/caddy /usr/bin/
RUN mkdir -p /etc/caddy

LABEL maintainer="andrewlunde <andrew.lunde@sap.com>"
