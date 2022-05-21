ARG DEBIAN_VERSION=bullseye

FROM ${DEBIAN_VERSION}-devel:latest

COPY --chown=root:root entrypoint.sh /

ENTRYPOINT ["bash", "/entrypoint.sh"]
