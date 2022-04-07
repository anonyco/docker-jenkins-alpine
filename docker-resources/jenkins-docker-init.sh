#!/bin/sh

echo
echo 'EXAMPLE USAGE: docker run --rm -it --name jenkins_docker --privileged -p 127.0.0.1:8080:8080 -v $PWD/certs/:/certs/:rw -v $PWD/var-lib-docker/:/var/lib/docker/:rw -v $PWD/jenkins_home/:/var/jenkins_home/:rw local/docker_jenkins:alpine3.15'
echo
echo

set -ev

# see the ENTRYPOINT in https://github.com/docker-library/docker/blob/30d7b9bf7663c96fcd888bd75e9aaa547a808a23/20.10/dind/Dockerfile
/bin/sh -c /usr/local/bin/dockerd-entrypoint.sh &
dockerPID=$!

if [ -n "$ADDITIONAL_PACKAGES" ]; then 
  apk add --cache-max-age 10080 --progress --force-old-apk --force-non-repository --force-broken-world --force-binary-stdout --allow-untrusted $ADDITIONAL_PACKAGES
fi

if [ -n "$DEBUG_KILLAFTER_SEC" ] ; then
  # kill this process after some time if debug flags say to do so
  /bin/sh -c "sleep $DEBUG_KILLAFTER_SEC ; kill $$" &
fi

# see the ENTRYPOINT and CMD in https://hub.docker.com/layers/jenkins/jenkins/jenkins/2.332.2-lts-alpine/images/sha256-4903ba0f5d251e72840eea65c2e4639e10fd23591b9ae2e4715c6bdc6eb5b2f4?context=explore
# the "-g jenkins" option seems to break this
sudo -EH -u jenkins /bin/sh -c /usr/local/bin/jenkins.sh "$@"

# after jenkins is killed, we kill docker too
kill $dockerPID

