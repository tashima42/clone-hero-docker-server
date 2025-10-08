FROM registry.suse.com/bci/bci-base:15.6 AS build-env

ARG TAG

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /clonehero

RUN zypper install -y unzip wget

COPY ./settings.ini .

RUN wget -qO libopenssl1_0_0.rpm https://download.opensuse.org/distribution/leap/15.6/repo/oss/x86_64/libopenssl1_0_0-1.0.2p-150000.3.91.1.x86_64.rpm

RUN wget -qO chserver.zip https://github.com/clonehero-game/releases/releases/download/${TAG}/CloneHero-standalone_server.zip \
 && unzip chserver.zip

RUN mv ./ChStandaloneServer-*-final/linux-x64/Server ./Server

RUN chmod +x ./Server


FROM registry.suse.com/bci/bci-base:15.6

RUN useradd -m clonehero

COPY --from=build-env /clonehero/libopenssl1_0_0.rpm .
RUN zypper --non-interactive install libopenssl1_0_0.rpm

RUN zypper --non-interactive install icu

RUN mkdir /usr/src/clonehero && chown clonehero /usr/src/clonehero
USER clonehero
WORKDIR /usr/src/clonehero

COPY --from=build-env /clonehero/Server ./Server

ENV NAME="Clone Hero Docker Server"
ENV PASS="test"
ENV IP="0.0.0.0"
ENV PORT="14242"

EXPOSE ${PORT}/udp
ENTRYPOINT /usr/src/clonehero/Server -a ${IP} -p ${PORT} -n ${NAME} -ps ${PASS}
