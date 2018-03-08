#!/bin/bash

echo "Genarate JENKINS SSH KEY and add it to gitlab"
host=$GIT_SERVER_HOST_NAME
port=$GIT_SERVER_PORT
gerrit_provider_id="adop-gitlab"
gerrit_protocol="ssh"
username=$GIT_USERNAME
password=$GIT_PASSWORD
nohup /usr/share/jenkins/ref/adop\_scripts/generate_key.sh -c ${host} -p ${port} -u ${username} -w ${password} &

#echo "Setting up your default SCM provider - Gitlab..."
mkdir -p $PLUGGABLE_SCM_PROVIDER_PROPERTIES_PATH $PLUGGABLE_SCM_PROVIDER_PATH
mkdir -p ${PLUGGABLE_SCM_PROVIDER_PROPERTIES_PATH}/CartridgeLoader ${PLUGGABLE_SCM_PROVIDER_PROPERTIES_PATH}/ScmProviders
#nohup /usr/share/jenkins/ref/adop\_scripts/generate_gerrit_scm.sh -i ${gerrit_provider_id} -p ${gerrit_protocol} -h ${host} &

echo "Tokenising scriptler scripts..."
sed -i "s,###SCM_PROVIDER_PROPERTIES_PATH###,$PLUGGABLE_SCM_PROVIDER_PROPERTIES_PATH,g" /usr/share/jenkins/ref/scriptler/scripts/retrieve_scm_props.groovy

echo "skip upgrade wizard step after installation"
echo "2.89.4" > /var/jenkins_home/jenkins.install.UpgradeWizard.state

echo "moving shared libraries xml config into Jenkins Home folder"
cp /usr/share/jenkins/ref/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml /var/jenkins_home
cp /var/jenkins_home/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml /var/jenkins_home/org.jenkinsci.plugins.workflow.libs.GlobalLibraries_source.xml

echo "tokenising shared library xml"
echo "JENKINS_SHARED_LIBRARY="${JENKINS_SHARED_LIBRARY}
echo "AEM_SHARED_LIBRARY="${AEM_SHARED_LIBRARY}
envsubst < /var/jenkins_home/org.jenkinsci.plugins.workflow.libs.GlobalLibraries_source.xml > /var/jenkins_home/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml

echo "start filebeat"
/etc/init.d/filebeat start

echo "start JENKINS"
chown -R 1000:1000 /var/jenkins_home
su jenkins -c /usr/local/bin/jenkins.sh
