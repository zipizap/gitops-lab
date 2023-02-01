kf() { kubecolor --force-colors get $(kubectl api-resources | grep -i flux | cut -d' ' -f1 | tr '\n' ',' | sed 's/,$//g') -A; }
while :;do sleep 5; kf &> /tmp/a; clear; date; cat /tmp/a ; done
 
