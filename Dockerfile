FROM ubuntu:16.10

MAINTAINER manovotn

RUN apt-get update; apt-get install -y \
    software-properties-common \
    python-software-properties \
    wget -y \
    vim -y \
    unzip -y

#get Java, this should set JAVA_HOME as well
RUN apt-get install openjdk-8-jdk -y
RUN apt-get update -y

#get Maven 3.3.9
RUN wget http://apache.mirror.anlx.net/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
RUN tar -zxf apache-maven-3.3.9-bin.tar.gz
RUN cp -R apache-maven-3.3.9 /usr/local
RUN ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
RUN ln -s /usr/local/apache-maven-3.3.9/bin/mvnDebug /usr/bin/mvnDebug

#get some Git
RUN apt-get install git -y

#clone Weld repo at 2.4 branch
RUN git clone https://github.com/weld/core.git -b 2.4

#trigger build of JSF numberguess
RUN mvn clean install -f core/examples/jsf/numberguess/pom.xml -DskipTests

#fetch me a server!
RUN wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip
RUN unzip wildfly-10.1.0.Final.zip

#copy weld app into WildFly
RUN cp core/examples/jsf/numberguess/target/weld-numberguess.war wildfly-10.1.0.Final/standalone/deployments/

# if you run this image in -it mode, then you get into badh
#CMD "/bin/bash"

#what we really only crave here, is to start the server
CMD "wildfly-10.1.0.Final/bin/standalone.sh"
