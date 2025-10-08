FROM registry.suse.com/bci/bci-base:15.7 AS build-env

ARG TAG

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /clonehero

RUN zypper install -y unzip wget

COPY ./settings.ini .

RUN wget -qO chserver.zip https://github.com/clonehero-game/releases/releases/download/${TAG}/CloneHero-standalone_server.zip \
 && unzip chserver.zip \

RUN mv ./ChStandaloneServer-linux-x64/* .

RUN chmod +x ./Server \
 && chown -R 777 ./config

FROM registry.suse.com/bci/bci-base:15.7

RUN ln -sf /usr/src/clonehero/Server /usr/bin/cloneheroserver \
 && useradd -m clonehero

WORKDIR /usr/src/clonehero
RUN chown -R 777 .
RUN chmod -R 777 .
COPY --from=build-env /clonehero .
USER clonehero

WORKDIR /usr/src/clonehero

ENV NAME="Clone Hero Docker Server"
ENV PASS="test"
ENV IP="0.0.0.0"
ENV PORT="14242"

EXPOSE 14242/udp
ENTRYPOINT ./Server -a "${IP}" -p "${PORT}" -n "${NAME}" -ps "${PASS}"
