FROM centos:7

MAINTAINER Matej Novotny <manovotn@redhat.com>

# Install packages necessary to run EAP/WFLY
RUN yum update -y && yum -y install xmlstarlet saxon augeas bsdtar unzip wget && yum clean all

# Create a userused to launch processes
# We add it to group 0 (root), user ID will be changed later on!!
RUN useradd -u 1000 -r -g 0 -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss
RUN chmod 755 /opt/jboss

# Set the working directory to jboss' user home directory 
WORKDIR /opt/jboss

# User root user to install software 
USER root 

# Install necessary packages 
RUN yum -y install java-1.8.0-openjdk-devel && yum clean all 

# Switch back to jboss user 
USER jboss 

# Set the JAVA_HOME variable to make it clear where Java is located 
ENV JAVA_HOME /usr/lib/jvm/java

# Set the WILDFLY_VERSION && WELD_VERSION env variable
ENV WILDFLY_VERSION 10.1.0.Final
ENV WILDFLY_SHA1 9ee3c0255e2e6007d502223916cefad2a1a5e333
ENV WELD_VERSION 2.4.2.SP1
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

#Expose ports
EXPOSE 8080
EXPOSE 9990

# Obtain patch for WildFly
RUN wget http://download.jboss.org/weld/$WELD_VERSION/wildfly-$WILDFLY_VERSION-weld-$WELD_VERSION-patch.zip -O wildfly-patch.zip

# Apply patch
RUN $JBOSS_HOME/bin/jboss-cli.sh --command="patch apply wildfly-patch.zip"

# Obtain weld-numberguess WAR
RUN wget https://repo1.maven.org/maven2/org/jboss/weld/examples/jsf/weld-jsf-numberguess/$WELD_VERSION/weld-jsf-numberguess-$WELD_VERSION.war -O weld-numberguess.war

# Copy numberguess to WildFly deployments
RUN cp weld-numberguess.war wildfly/standalone/deployments/

# Now, we try to change user ID in order to trick OpenShift and get sufficient rights to execute WFLY
USER root
RUN sed -i 's/1000/1052340000/g' /etc/passwd
USER jboss

#Start WildFly, note that need to pass in special regex for Probe to allow remote access from all addresses
CMD ["wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-Dorg.jboss.weld.probe.allowRemoteAddress=.*"]
