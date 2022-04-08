# we build this based off jenkins ci instead of based off alpine
#FROM alpine:3.15
# 2.332.2-lts-alpine is JDK11
#FROM jenkins/jenkins:2.332.2-lts-alpine


ARG JENKINS_BASE_IMAGE=lts-alpine-jdk11
FROM jenkins/jenkins:$JENKINS_BASE_IMAGE

# set user to root and restore CMD/ENTRYPOINT temporarily
USER root:root
ENTRYPOINT []
CMD ["/bin/sh"]

##########################################################################################################################################
# first part is from https://github.com/docker-library/docker/blob/4c51639763865cc04cff127ea50e96ff377b6723/20.10/Dockerfile
##########################################################################################################################################

ARG DOCKER_VERSION=20.10.14
ENV DOCKER_VERSION=$DOCKER_VERSION
LABEL DOCKER_VERSION=$DOCKER_VERSION

ARG DOCKER_COMPOSE_VERSION=v2.2.3
ENV DOCKER_COMPOSE_VERSION=$DOCKER_COMPOSE_VERSION
LABEL DOCKER_COMPOSE_VERSION=$DOCKER_COMPOSE_VERSION

# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs

RUN set -eux; \
    apk add --no-cache \
		ca-certificates \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client; \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
#		libc6-compat \
# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/docker/docker-ce/blob/v17.09.0-ce/components/engine/hack/make.sh#L149
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
    if [ ! -e /etc/nsswitch.conf ] ; then echo 'hosts: files dns' > /etc/nsswitch.conf ; fi; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz"; \
			;; \
		'armhf') \
			url="https://download.docker.com/linux/static/stable/armel/docker-$DOCKER_VERSION.tgz"; \
			;; \
		'armv7') \
			url="https://download.docker.com/linux/static/stable/armhf/docker-$DOCKER_VERSION.tgz"; \
			;; \
		'aarch64') \
			url="https://download.docker.com/linux/static/stable/aarch64/docker-$DOCKER_VERSION.tgz"; \
			;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O docker.tgz "$url"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version; \
#COPY modprobe.sh /usr/local/bin/modprobe
#COPY docker-entrypoint.sh /usr/local/bin/
    wget -O /usr/local/bin/modprobe "https://raw.githubusercontent.com/docker-library/docker/387e351394bfad74bceebf8303c6c8e39c3d4ed4/20.10/modprobe.sh"; \
    chmod +x /usr/local/bin/modprobe; \
    wget -O /usr/local/bin/docker-entrypoint.sh "https://raw.githubusercontent.com/docker-library/docker/4c51639763865cc04cff127ea50e96ff377b6723/20.10/docker-entrypoint.sh"; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
    mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]

##########################################################################################################################################
# second part is from https://github.com/docker-library/docker/blob/30d7b9bf7663c96fcd888bd75e9aaa547a808a23/20.10/dind/Dockerfile
##########################################################################################################################################

# we are already basing this off docker because of the continuation from before
#FROM docker:20.10

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 42b1175eda071c0e9121e1d64345928384a93df1

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN set -eux; \
	apk add --no-cache \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
		ip6tables \
		iptables \
		openssl \
		shadow-uidmap \
		xfsprogs \
		xz \
# pigz: https://github.com/moby/moby/pull/35697 (faster gzip implementation)
		pigz \
	; \
# only install zfs if it's available for the current architecture
# https://git.alpinelinux.org/cgit/aports/tree/main/zfs/APKBUILD?h=3.6-stable#n9 ("all !armhf !ppc64le" as of 2017-11-01)
# "apk info XYZ" exits with a zero exit code but no output when the package exists but not for this arch
	if zfs="$(apk info --no-cache --quiet zfs)" && [ -n "$zfs" ]; then \
		apk add --no-cache zfs; \
	fi; \
# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    addgroup -S dockremap; \
    adduser -S -G dockremap dockremap; \
    echo 'dockremap:165536:65536' >> /etc/subuid; \
    echo 'dockremap:165536:65536' >> /etc/subgid; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind; \
    wget -O /usr/local/bin/dockerd-entrypoint.sh "https://raw.githubusercontent.com/docker-library/docker/0efba9e3cd4537de89ba54de2ad8acc5e3b1759f/20.10/dind/dockerd-entrypoint.sh"; \
	chmod +x /usr/local/bin/dockerd-entrypoint.sh
#COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

#ENTRYPOINT ["dockerd-entrypoint.sh"]
#CMD []

##########################################################################################################################################
# third part is my own design to restore things and set things right
##########################################################################################################################################

CMD ["/bin/sh"]
ENTRYPOINT []

#COPY .auto-gen/localtime /etc/localtime
#COPY .auto-gen/timezone /etc/timezone

COPY nopasswd /etc/sudoers.d/
COPY jenkins-docker-init.sh /usr/local/bin/

RUN apk add --no-cache sudo shadow \
 && apk update \
 && apk upgrade \
 && addgroup -g 142 -S docker \
 && usermod -a -G docker jenkins \
 && addgroup -S sudo \
 && usermod -a -G sudo jenkins \
 && chown -R jenkins:jenkins /var/jenkins_home \
 && mkdir -p /var/cache/apk \
 && ln -sf /var/cache/apk /etc/apk/cache \
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -sSLo /usr/local/lib/docker/cli-plugins/docker-compose "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64" \
 && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
 && docker compose version \
 && curl -sSLo /usr/local/bin/docker-compose 'https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64' \
 && chmod +x /usr/local/bin/docker-compose \
 && docker-compose --version


VOLUME /var/jenkins_home

#ENV LANG=C.UTF-8
#ENV JENKINS_HOME=/var/jenkins_home
#ENV JENKINS_SLAVE_AGENT_PORT=50000
#ENV REF=/usr/share/jenkins/ref
#ENV JENKINS_VERSION=2.332.2
#ENV JENKINS_UC=https://updates.jenkins.io
#ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
#ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
#ENV COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log
#ENV JAVA_HOME=/opt/java/openjdk
#ENV PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER root:root
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins-docker-init.sh"]


