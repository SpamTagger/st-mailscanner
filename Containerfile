ARG DISTRO=trixie
FROM debian:${DISTRO}

ARG MAILSCANNER_VERSION
ARG ARCH
ARG CPUS

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
    apt-utils \
    build-essential \
    ca-certificates \
    git \
    pkg-config && \
  rm -rf /var/lib/apt/lists/*

RUN useradd mailscanner --system --create-home --user-group \
  --home-dir /var/spamtagger/spool/mailscanner \
  --shell /usr/sbin/nologin

RUN git clone https://github.com/MailScanner/v5.git --depth=1 && \
  cd v5 && \
  git fetch --tags && git checkout ${MAILSCANNER_VERSION} && \
  UPSTREAM_SHA=$(git rev-parse --short HEAD) && \
  echo $UPSTREAM_SHA && \
  cd - && \
  git clone https://github.com/SpamTagger/MailScanner-v5.git && \
  cd MailScanner-v5 && \
  git pull && \
  git diff $UPSTREAM_SHA > ../v5/spamtagger.patch && \
  cat ../v5/spamtagger.patch

WORKDIR v5
RUN git apply spamtagger.patch
RUN sed -iR 's/mtagroup/spamtagger/g' ./
RUN ./Build.debian

CMD lintian /root/msbuilds/MailScanner-${MAILSCANNER_VERSION}.noarch.deb
