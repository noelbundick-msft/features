#!/bin/sh
set -e

echo "Activating feature 'gitops'"
echo "The provided gitops toolchain color is: ${GITOPS}"
echo "The provided k8s development environment is: ${CLUSTER}"

if [ "$GITOPS" = "flux" ]; then
  curl -s https://fluxcd.io/install.sh | sudo bash
  sudo chmod +x /usr/local/bin/flux
else
  echo "Unknown gitops toolchain: ${GITOPS}"
fi

if [ "$CLUSTER" = "k3d" ]; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
  echo "Unknown k8s development environment: ${CLUSTER}"
fi

cat > /usr/local/share/gitops-init.sh \
<< EOF
#!/bin/sh

while true; do
  if docker ps >/dev/null 2>&1; then
    echo 'Creating cluster'
    k3d cluster create
    break
  else
    echo 'Waiting for docker...'
    sleep 1
    continue
  fi
done &

EOF

chmod +x /usr/local/share/gitops-init.sh
