```shell
docker pull jenkinsci/blueocean:1.24.7

# Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions
# -u 覆盖容器中内置的帐号，该用外部传入，这里传入0代表的是root帐号Id
docker run -p 8599:8080 -p 50000:50000 --name jenkins-server -u 0 -v /www/server/docker-srv/jenkins/data:/var/jenkins_home jenkinsci/blueocean:1.24.7

```