FROM registry.access.redhat.com/rhel7/rhel-atomic 
MAINTAINER Veer Muchandi<veer@redhat.com>

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

RUN microdnf install -y --enablerepo=rhel-7-server-rpms openssh-clients sudo git wget openssl bash-completion passwd hostname && \
    wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -ivh epel-release-latest-7.noarch.rpm && \
    microdnf install -y shellinabox && \
    microdnf install atomic-openshift-clients --enablerepo="rhel-7-server-ose-3.9-rpms" -y && \
    microdnf clean all  && \
    if [ -e /var/run/nologin ]; then mv /var/run/nologin /var/run/nologin.bak; fi

EXPOSE 4200

ADD assets/entrypoint.sh /usr/local/sbin/

ENTRYPOINT ["entrypoint.sh"]
CMD ["shellinabox"]
