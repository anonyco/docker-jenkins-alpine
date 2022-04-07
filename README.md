

<!--![alt text](./artwork/combined_image.png)-->
<p align="center">
	<img src="artwork/logo165x127.png" alt="Jenkins holding docker in one hand to serve to you" width="165" style="max-width:165px"/>
</a>

# Jenkins+Docker in Alpine

This simple project mix-mashes Jenkins, Docker, and Alpine all into one docker container you can run on Linux AMD64. I also have a build cronjob running on my main desktop that updates and tests the image every day. Notice that it only performs two tests: (1.) that the Jenkins CI is hosting an HTTP server, and (2.) that docker containers can be runned as the Jenkins user. Additional tests are a welcome addition if you would like to contribute. It is possible for these tests to pass but unforseen issues to arise, so I would reccomend only using latest if you're going to be around to resolve issues if they arise.

### Image credits

The logo for this project was put together using KolorPaint with images sourced from the links below:

* [https://www.meetup.com/Seattle-Jenkins-Area-Meetup/](https://www.meetup.com/Seattle-Jenkins-Area-Meetup/)
* [https://www.docker.com/company/newsroom/media-resources/](https://www.docker.com/company/newsroom/media-resources/)


