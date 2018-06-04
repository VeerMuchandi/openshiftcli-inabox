# Openshift CLI Shell In A Box

This repository uses shellinabox. This is ShellInABox+OpenShift Client tools. 

## Notes
* This Dockerfile uses RHEL-Atomic Image `registry.access.redhat.com/rhel7/rhel-atomic`
* You need a box with RH Subscription to be able to build this image. 
* All dependencies needed by openshift-cli are added to this image along with ShellInABox. ShellInABox comes from EPEL
* `/var/run/nologin` removed (moved) to allow user login
* shellinaboxd running with `--disable-peer-check` so that the connection is not reset every few mins due to container running behind a load balancer
* This container runs as root as you want to add additional users to this shell. So the openshift admin needs to provide `anyuid` access to the service account used to run this container. `oc adm policy add-scc-to-user anyuid -z default -n inabox`


## Deploying on OpenShift
Create a new project
```
$ oc new-project inabox
```

Choose a password to login as user `guest` into the shellinabox
```
$ export MYPASSWORD=<<Your Guest Password>>
```

Deploy OpenShift CLI ShellInABox application.

```
$ oc new-app https://github.com/VeerMuchandi/openshiftcli-inabox --name=cliinbox -e SIAB_PASSWORD=$MYPASSWORD
--> Found Docker image 05a7a26 (3 weeks old) from registry.access.redhat.com for "registry.access.redhat.com/rhel7/rhel-atomic"              
                                                                                                                                             
    Red Hat Enterprise Linux 7                                                                                                               
    --------------------------                                                                                                               
    The Red Hat Enterprise Linux Base image is designed to be a minimal, fully supported base image where several of the traditional operatin
g system components such as python an systemd have been removed. The Atomic Image also includes a simple package manager called microdnf whic
h can add/update packages as needed.                                                                                                         
                                                                                                                                             
    Tags: minimal rhel7                                                                                                                      
                                                                                                                                             
    * An image stream will be created as "rhel-atomic:latest" that will track the source image                                               
    * A Docker build using source code from https://github.com/VeerMuchandi/openshiftcli-inabox will be created                              
      * The resulting image will be pushed to image stream "cliinbox:latest"                                                                 
      * Every time "rhel-atomic:latest" changes a new build will be triggered                                                                
    * This image will be deployed in deployment config "cliinbox"                                                                            
    * Port 4200 will be load balanced by service "cliinbox"                                                                                  
      * Other containers can access this service through the hostname "cliinbox"                                                             
    * WARNING: Image "registry.access.redhat.com/rhel7/rhel-atomic" runs as the 'root' user which may not be permitted by your cluster admini
strator                                                                                                                                      
                                                                                                                                             
--> Creating resources ...                                                                                                                   
    imagestream "rhel-atomic" created                                                                                                        
    imagestream "cliinbox" created                                                                                                           
    buildconfig "cliinbox" created                                                                                                           
    deploymentconfig "cliinbox" created                                                                                                      
    service "cliinbox" created                                                                                                               
--> Success                                                                                                                                  
    Build scheduled, use 'oc logs -f bc/cliinbox' to track its progress.                                                                     
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:                 
     'oc expose svc/cliinbox'                                                                                                                
    Run 'oc status' to view your app.
```

Expose the service to create a route

```
$ oc get svc                                                                                                            
NAME       CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE                                                                                     
cliinbox   172.30.123.236   <none>        4200/TCP   1m  

$ oc expose svc cliinbox                                                                                                
route "cliinbox" exposed                             

$ oc get route                                                                                                          
NAME       HOST/PORT                                 PATH      SERVICES   PORT       TERMINATION   WILDCARD                                  
cliinbox   cliinbox-occli.apps.devday.ocpcloud.com             cliinbox   4200-tcp                 None

```

Now you can use your route to access it from the browser.

Login using `guest` and password that you chose at the beginning. Run regular `oc` commands from command line.

### References

Concepts borrowed from 

[https://hub.docker.com/r/sspreitzer/shellinabox/~/dockerfile/](https://hub.docker.com/r/sspreitzer/shellinabox/~/dockerfile/)

[https://github.com/debianmaster/buildtools](https://github.com/debianmaster/buildtools)
