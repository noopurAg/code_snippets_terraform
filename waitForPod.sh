#Licensed Materials - Property of IBM
#(C) Copyright IBM Corp. 2016, 2017. All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi
namespace=$1

success="false"
for j in {1..10}
do
        i=0
        arr=()

    #`kubectl get pods -n ${namespace} > status.txt`
     `kubectl get -n ${namespace} pods > status.txt`
        while read LINE
        do
                status=`echo $LINE | awk '{print $3}'`

                #Skip the first iteration
                if [ "$status" == "STATUS" ]
                then
                        continue
                fi

                #Check which services are not in running state
                if [ "$status" != "Running" ]
                then
                        microservice=`echo $LINE | awk '{print $1}'`
                        arr[$i]=$microservice
                        let i++
                        echo "$microservice is not running"
                fi


        done < status.txt

        #After each iteration check if all the services are in running state or wait for 60s and try again
        if [ $i -gt 0 ]
        then
           echo "Wait for 10 Seconds and then check again"
           sleep 10
        else
             echo "All the services are in running state"
             success="true"
             exit 0
        fi

done

if [ $success == "false" ]
then
    echo "Services are not in running state even after multiple attempts"
        echo -e "\nFollowing services are not running : \n${arr[@]}"
        exit 1
fi
