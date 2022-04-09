

<!--![alt text](./artwork/combined_image.png)-->
<p align="center">
	<img src="artwork/logo165x127.png" alt="Jenkins holding docker in one hand to serve to you" width="165" style="max-width:165px"/>
</a>

# Jenkins+Docker in Alpine

This simple project mix-mashes Jenkins, Docker, docker-compose, `docker compose`, and Alpine all into one docker container you can run on Linux AMD64. I also have a build cronjob running on my main desktop that updates and tests the image for basic functionality every day (an image will never be pushed if either docker, jenkins, docker-compose, or the `docker compose` plugin are non-functional):

```
docker run --rm --name your_friendly_name_here --privileged -p 8080:8080 -v "$PWD/certs/:/certs/:rw" -v "$PWD/var-lib-docker/:/var/lib/docker/:rw" -v "$PWD/jenkins_home/:/var/jenkins_home/:rw" -v "$PWD/var-cache-apk:/var/cache/apk:rw" jackanonyco/docker-jenkins-alpine:jdk11
```

See the Docker Hub repo at [https://hub.docker.com/r/jackanonyco/docker-jenkins-alpine](https://hub.docker.com/r/jackanonyco/docker-jenkins-alpine)

### Image credits

The logo for this project was put together using KolorPaint with images sourced from the links below:

* [https://www.meetup.com/Seattle-Jenkins-Area-Meetup/](https://www.meetup.com/Seattle-Jenkins-Area-Meetup/)
* [https://www.docker.com/company/newsroom/media-resources/](https://www.docker.com/company/newsroom/media-resources/)


