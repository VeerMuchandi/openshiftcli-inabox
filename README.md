# Openshift CLI Shell In A Box

This repository uses shellinabox. This is ShellInABox+OpenShift Client tools. 

## Notes
* This Dockerfile uses UBI Minimal image `registry.access.redhat.com/ubi8/ubi-minimal`
* You need a box with RHEL8 box with RH Subscription to be able to build this image. The entitlements and subscription manager configuration are copied from this box. This is required to run UBI builds on an OCP 4.x cluster as (unlike in OCP 3.x) the underlying node on which the build runs may not be subscribed using RHSM to RedHat.
* All dependencies needed by openshift-cli are added to this image along with ShellInABox. ShellInABox comes from EPEL
* `/var/run/nologin` removed (moved) to allow user login
* shellinaboxd running with `--disable-peer-check` so that the connection is not reset every few mins due to container running behind a load balancer
* This container runs as root as you want to add additional users to this shell. So the openshift admin needs to provide `anyuid` access to the service account used to run this container. 

```
oc adm policy add-scc-to-user anyuid -z default -n inabox
```


## Deploying on OpenShift

**PLEASE READ NOTES BEFORE PROCEEDING FURTHER**

**RUN THE FOLLOWING COMMANDS FROM A RHEL8 BOX THAT HAS REDHAT SUBSCRIPTIONS**

Create a new project
```
# /usr/local/bin/oc new-project inabox
```

Entitlements for your RHEL8 box are in the folder `/etc/pki/entitlement`. There are two files with the filename format `{ID}.pem` and `{ID}-key.pem`. Create a secret as shown below. **NOTE** your `{ID}` would be different. So don't just copy paste.

```
# /usr/local/bin/oc create secret generic etc-pki-entitlement --from-file /etc/pki/entitlement/1708460257780024328.pem --from-file /etc/pki/entitlement/1708460257780024328-key.pem

secret/etc-pki-entitlement created
```

Create ConfigMap for subscription-manager configuration from `/etc/rhsm/rhsm.conf`

```
# /usr/local/bin/oc create configmap rhsm-conf --from-file /etc/rhsm/rhsm.conf 
configmap/rhsm-conf created
```

Create another ConfigMap for subscription-manager CA.

```
# /usr/local/bin/oc create configmap rhsm-ca --from-file /etc/rhsm/ca/redhat-uep.pem 
configmap/rhsm-ca created
```

Create a Build on the OpenShift Cluster by running the following command. This will mount the entitlements as secret and configmaps to use during build

```
oc new-build https://github.com/VeerMuchandi/openshiftcli-inabox#4.3 \
--name=cli \
--build-secret="etc-pki-entitlement:etc-pki-entitlement" \
--build-config-map="rhsm-conf:rhsm-conf" \
--build-config-map="rhsm-ca:rhsm-ca"
```
Wait until the build completes.


Choose a password to login as user `guest` into the shellinabox
```
$ export MYPASSWORD=<<Your Guest Password>>
```

Deploy OpenShift CLI ShellInABox application bow

```
$ oc new-app cli -e SIAB_PASSWORD=$MYPASSWORD
```

Expose the service to create a route

```
$ oc get svc                                                                                                            
NAME       CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE                                                                                     
cli       172.30.123.236   <none>        4200/TCP   1m  

$ oc expose svc cli                                                                                               
route "cli" exposed                             

$ oc get route                                                                                                          
NAME       HOST/PORT                                 PATH      SERVICES   PORT       TERMINATION   WILDCARD                                  
cliinbox   cli-inbox.apps.devday.ocpcloud.com             cliinbox   4200-tcp                 None

```

If the deployment doesn't start you may have to rollout the deployment by running `oc rollout latest dc/cli`

Now you can use your route to access it from the browser.

Login using `guest` and password that you chose at the beginning. Run regular `oc` commands from command line.

### Deploying with a bunch of users provisioned with your cliinabox

Cleanup the last deployment

```
oc delete all -l app=cli
```

```
$ export USERPASSWORD=<<Your User Password>>
```

Use the following command to create the application that provisions 25 users. 

```
oc new-app cli \
-e SIAB_PASSWORD=$MYPASSWORD \
-e USER_COUNT=25 \
-e USER_PASSWORD=$USERPASSWORD \
SIAB_SCRIPT=https://raw.githubusercontent.com/VeerMuchandi/openshiftcli-inabox/master/addusers.sh

```

Expose service

```
oc expose svc cli
```

Now you can login as user1, user2 etc.

### References

Concepts borrowed from 

[https://hub.docker.com/r/sspreitzer/shellinabox/~/dockerfile/](https://hub.docker.com/r/sspreitzer/shellinabox/~/dockerfile/)

[https://github.com/debianmaster/buildtools](https://github.com/debianmaster/buildtools)
