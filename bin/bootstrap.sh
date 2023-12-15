#!/bin/bash
# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

apt update
# install snapd
apt install snapd -y

# install microk8s
snap install microk8s --classic

# write kube config for user: vagrant
/usr/bin/mkdir -p /home/vagrant/.kube
/snap/bin/microk8s config > /home/vagrant/.kube/config
/usr/sbin/usermod -a -G microk8s vagrant
/usr/bin/chown -f -R vagrant /home/vagrant/.kube

# install required microk8s addons
/snap/bin/microk8s enable community
/snap/bin/microk8s enable metallb:192.168.60.100-192.168.60.200

# install kubernetes dashboard
/snap/bin/microk8s enable dashboard
# wait until kubernetes dashboard is initialized
while /snap/bin/microk8s kubectl get pods --namespace kube-system | grep '0/1'; do sleep 1; done
# Make kubernetes dashboard available on it's own IP
/snap/bin/microk8s kubectl patch svc kubernetes-dashboard -n kube-system -p '{"spec": {"type": "LoadBalancer"}}'

# install argocd addon
/snap/bin/microk8s enable argocd
# wait until argocd is initialized
while /snap/bin/microk8s kubectl get pods --namespace argocd | grep '0/1'; do sleep 1; done
# Make argocd server available on it's own IP
/snap/bin/microk8s kubectl patch svc argo-cd-argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
/snap/bin/microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /root/argocd_admin_pwd.txt
# install argocd cli
/usr/bin/curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
/usr/bin/install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
/usr/bin/rm argocd-linux-amd64

# install tekton
/snap/bin/microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
while /snap/bin/microk8s kubectl get pods --namespace tekton-pipelines | grep '0/1'; do sleep 1; done
/snap/bin/microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
while /snap/bin/microk8s kubectl get pods --namespace tekton-pipelines | grep '0/1'; do sleep 1; done
/snap/bin/microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
while /snap/bin/microk8s kubectl get pods --namespace tekton-pipelines | grep '0/1'; do sleep 1; done

# echo kubernetes dashboard url and login token
/usr/bin/echo kubernetes dashboard is available at https://$(/snap/bin/microk8s kubectl get service kubernetes-dashboard -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
token=$(/snap/bin/microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1) && /snap/bin/microk8s kubectl -n kube-system describe secret $token | grep 'token:'
# echo argocd url and initial admin password
/usr/bin/echo argocd is available at https://$(/snap/bin/microk8s kubectl get service argo-cd-argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
/usr/bin/echo argocd initial admin password: $(cat /root/argocd_admin_pwd.txt)
