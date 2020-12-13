FROM jenkins/jenkins:2.270

LABEL Author="Clecio Antao" 

ARG master_image_version="1"
ENV master_image_version $master_image_version
ARG MAVEN_VERSION=3.6.3

USER root

# Java
RUN apt-get update && apt-get install -y make git openjdk-8-jdk
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Maven
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_VERSION=${MAVEN_VERSION}
ENV M2_HOME /usr/share/maven
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

USER jenkins

# Para configuracoes de Seguranca
COPY .ssh/* /var/jenkins_home/.ssh/

# Plugins Install
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Auto Setup Scripts
COPY src/main/groovy/* /usr/share/jenkins/ref/init.groovy.d/
COPY src/main/resources/*.properties /var/jenkins_home/config/
COPY src/main/resources/initials/*.file /var/jenkins_home/config/initials/

# Copy Java e Maven
COPY src/files/* /var/jenkins_home/downloads/
