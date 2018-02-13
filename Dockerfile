FROM registry.access.redhat.com/rhel7-atomic

ENV SIAB_VERSION=2.19 \
  SIAB_USERCSS="Colors:+/usr/share/shellinabox/color.css,Normal:-/usr/share/shellinabox/white-on-black.css,Monochrome:-/usr/share/shellinabox/monochrome.css" \
  SIAB_PORT=4200 \
  SIAB_ADDUSER=true \
  SIAB_USER=guest \
  SIAB_USERID=1000 \
  SIAB_GROUP=guest \
  SIAB_GROUPID=1000 \
  SIAB_PASSWORD=putsafepasswordhere \
  SIAB_SHELL=/bin/bash \
  SIAB_HOME=/home/guest \
  SIAB_SUDO=false \
  SIAB_SSL=false \
  SIAB_SERVICE=/:LOGIN \
  SIAB_PKGS=none \
  SIAB_PKGS2=none \
  SIAB_SCRIPT=none

RUN microdnf install -y --enablerepo=rhel-7-server-rpms openssh-clients sudo git && \
    microdnf -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \ 
    microdnf install -y shellinabox && \
    microdnf install atomic-openshift-clients --enablerepo="rhel-7-server-ose-3.7-rpms" -y && \
    microdnf clean all

EXPOSE 4200

ADD assets/entrypoint.sh /usr/local/sbin/

ENTRYPOINT ["entrypoint.sh"]
CMD ["shellinabox"]
