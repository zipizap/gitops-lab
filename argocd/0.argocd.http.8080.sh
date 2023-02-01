set -x

ARGO_ADMIN_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
cat <<EOT
>> open in firefox-socks5
  https://localhost:8080  
  admin // ${ARGO_ADMIN_PASS}
EOT

kubectl port-forward svc/argocd-server -n argocd 8080:443
