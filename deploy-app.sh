#!/usr/bin/bash
PROJECT="review-troubleshoot"

# Identify the mysql pod
if [ $(oc get pods -l deploymentconfig=mysql -n ${PROJECT} -o name | wc -l) -eq 1 ]
then
  # mysql application was created as a deploymentconfig
  MYPOD=$(oc get pods -l deploymentconfig=mysql -n ${PROJECT} -o template --template '{{range .items}}{{.metadata.name}}{{end}}')
elif [ $(oc get pods -l deployment=mysql -n ${PROJECT} -o name | wc -l) -eq 1 ]
then
  # mysql application was created as a deployment
  MYPOD=$(oc get pods -l deployment=mysql -n ${PROJECT} -o template --template '{{range .items}}{{.metadata.name}}{{end}}')
fi

# Check if the "defaultdb" database already exists
if ! oc exec ${MYPOD} -n ${PROJECT} -- /usr/bin/mysql -u root -e 'show databases;' | grep -q defaultdb
then
  echo "Creating famous-quotes database"
  oc exec ${MYPOD} -n ${PROJECT} -- /usr/bin/mysql -u root -e 'CREATE DATABASE defaultdb'
fi

echo "Deploying famous-quotes application"

oc apply -f /home/student/DO280/labs/${PROJECT}/famous-quotes.yaml
