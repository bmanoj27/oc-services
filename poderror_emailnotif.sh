#!/bin/bash

#nonrunpod=$(oc get pods -A | grep -v Running | grep -v Completed)

#Change the API Endpoint here.
oc login -u kubeadmin -p $(cat /root/ftm4c/auth/kubeadmin-password) https://<API-ENDPOINT>:6443


count_non=$(oc get pods -A --no-headers | grep -v Running | grep -v Completed | wc -l)

if [[ ${count_non} -gt 0 ]]; then

# Define recipient email address
recipient="<recipient-email-address>"

# Define email subject
subject="Failed/Error Pods in ftm4c Cluster at $(date "+%B %d %Y, %I:%M:%S %p")"

# Define sender name
sender_name=$(oc whoami)
hhh=$(hostname)
tabes=$(echo -e "NAMESPACE \t\t NAME")
failed_pods=$(oc get pods -A --no-headers | grep -v Running | grep -v Completed | awk '{print $1 "\t""\t" $2}')

# Create the email content
email_content=$(cat <<EOF
Hello,

Here is the current status of the OpenShift cluster at $(date "+%B %d %Y, %I:%M:%S %p")
Check done by ${sender_name}
============================================================
Pods not running:
------------------------------------------------------------
${tabes}
${failed_pods}

============================================================


This is an automated email from ${sender_name}. Please do not reply.
Sent from ${hhh}
------------------------------------------------------------
EOF
)

# Send the email
echo "$email_content" | mailx -s "$subject" "$recipient"
#echo "$email_content"
exit 0
else

echo -e "No Failed Pods as of $(date "+%B %d %Y, %I:%M:%S %p") \n" >> /root/mail-test/email-log-pod_check.log
exit 0
fi

oc logout
exit 0
