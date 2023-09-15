#!/usr/bin/bash

PROJECT="review-template"
HOSTNAME="hello-secure.apps.ocp4.example.com"
HPA="hello-secure"

if sudo oc login -u admin -p redhat https://api.ocp4.example.com:6443 --insecure-skip-tls-verify &> /dev/null
then
  # Identify if HPA exists
  if sudo oc get hpa/${HPA} -n ${PROJECT} &> /dev/null
  then
    HPA_READY="false"
    HPA_LOOP_LIMIT=120
    HPA_LOOP_COUNT=0

    for POD in $(sudo oc get pods -o name -n ${PROJECT} | head -n1)
    do
      POD_CPU_REQUEST="$(sudo oc get ${POD} -n ${PROJECT} -o jsonpath='{.spec.containers[?(@.name=="hello-secure")].resources.requests.cpu}')"
    done

    if [ -n "${POD_CPU_REQUEST}" ]
    then
      CURRENT_CPU=$(sudo oc get hpa/${HPA} -n ${PROJECT} -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')
      if [ -z "${CURRENT_CPU}" ]
      then
        echo
        echo "============================================================"
        echo -n "Waiting up to five minutes for 'hpa/${HPA}': "

        while [ ${HPA_LOOP_COUNT} -lt ${HPA_LOOP_LIMIT} ]
        do
          CURRENT_CPU=$(sudo oc get hpa/${HPA} -n ${PROJECT} -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')
          if [ -n "${CURRENT_CPU}" ]
          then
            HPA_READY="true"
            echo "READY"
            echo "============================================================"
            echo
            break
          else
            sleep 5
            ((HPA_LOOP_COUNT=HPA_LOOP_COUNT+1))
          fi
        done

        if [ ${HPA_LOOP_COUNT} -eq ${HPA_LOOP_LIMIT} ]
        then
          echo "NOT READY"
          echo "============================================================"
        fi
      else
        HPA_READY="true"
      fi

      if [ "${HPA_READY}" == "true" ]
      then
        echo
        ab -c200 -k -dS -n100000 https://${HOSTNAME}/index.html
      fi
    else
      echo
      echo "ERROR: '${POD}' did not make a CPU request." 1>&2
      echo
    fi
  fi
fi
