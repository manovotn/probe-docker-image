FROM jboss/wildfly:10.1.0.Final

MAINTAINER manovotn

#Expose ports
EXPOSE 8080
EXPOSE 9990

#Handle user switching
#Install Maven and Git
USER root
RUN yum install wget -y
USER jboss

#Obtain weld-numberguess WAR
RUN wget https://repo1.maven.org/maven2/org/jboss/weld/examples/jsf/weld-jsf-numberguess/2.4.2.SP1/weld-jsf-numberguess-2.4.2.SP1.war -O weld-numberguess.war

#Copy to WildFly deployments
RUN cp weld-numberguess.war wildfly/standalone/deployments/

#Start WildFly, note that need to pass in special IP address for Probe to allow remote access (from container)
CMD ["wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-Dorg.jboss.weld.probe.allowRemoteAddress=172.17.0.1"]

