# probe-docker-image
Docker Image for Probe on OpenShift 3

This images works with WildFly, Weld patch and Weld numberguess application.
Usually, latest releases of the above will be used.

Wildfly is downloaded and modified with Weld patch. Numberguess app with enabled Probe is then moved into deployments.
Upon start of the container, Wildfly is automatically started and ports are exposed.

Whole image is designated to be deployed on OpenShift 3.


Update process:

* Edit WELD\_VERSION with desired released version
* Edit WILDFLY\_VERSION and WILDFLY\_SHA1 if WildFly is to be updated
* Build the image, tag it and push in Docker Hub
* This should automatically propagate into OpenShift and deploy
