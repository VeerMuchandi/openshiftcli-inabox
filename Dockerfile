FROM registry.access.redhat.com/ubi8/ubi-minimal 
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

USER root
# Copy entitlements
COPY ./etc-pki-entitlement /etc/pki/entitlement
# Copy subscription manager configurations
COPY ./rhsm-conf /etc/rhsm
COPY ./rhsm-ca /etc/rhsm/ca

RUN rm /etc/rhsm-host && \
    microdnf install -y --enablerepo=rhel-8-for-x86_64-baseos-rpms openssh-clients tar sudo git wget openssl bash-completion passwd hostname && \
    wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -ivh epel-release-latest-7.noarch.rpm && \
    microdnf install -y shellinabox && \
    wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.3.0.tar.gz && \
    tar -xvzf openshift-client-linux-4.3.0.tar.gz -C /usr/local/bin && \
    rm -f openshift-client-linux-4.3.0.tar.gz && \
    rm -f epel-release-latest-7.noarch.rpm && \
    curl -L https://mirror.openshift.com/pub/openshift-v4/clients/odo/latest/odo-linux-amd64 -o /usr/local/bin/odo && \
    chmod +x /usr/local/bin/odo && \
    curl -LO https://github.com/tektoncd/cli/releases/download/v0.6.0/tkn_0.6.0_Linux_x86_64.tar.gz && \
    tar xvzf tkn_0.6.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn && \
    rm -f tkn_0.6.0_Linux_x86_64.tar.gz && \
    curl https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64 -o /usr/local/bin/kn && \
    chmod +x /usr/local/bin/kn && \
    microdnf clean all  && \
    if [ -e /var/run/nologin ]; then mv /var/run/nologin /var/run/nologin.bak; fi


USER 1001
EXPOSE 4200

ADD assets/entrypoint.sh /usr/local/sbin/

ENTRYPOINT ["entrypoint.sh"]
CMD ["shellinabox"]
