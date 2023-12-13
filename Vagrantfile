# Check for plugins
unless Vagrant.has_plugin?("vagrant-auto_network")
  raise 'vagrant-auto_network is not installed!'
end
AutoNetwork.default_pool = '192.168.60.0/22'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-12"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 8192
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", host_ip: "127.0.0.1", auto_correct: true
  config.vm.network :private_network, :auto_network => true

  # microk8s install and provision
  config.vm.provision "shell", inline: <<-SHELL
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
    # install argocd addon
    /snap/bin/microk8s enable argocd
    # wait 30 seconds so argocd is initialized
    sleep 30
    # Make argocd server available on it's own IP
    /snap/bin/microk8s kubectl patch svc argo-cd-argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    /snap/bin/microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /root/argocd_admin_pwd.txt
    # install argocd cli
    /usr/bin/curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    /usr/bin/install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    /usr/bin/rm argocd-linux-amd64
    # echo argocd url and initial admin password
    /usr/bin/echo argocd is available at https://$( /snap/bin/microk8s kubectl get service argo-cd-argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    /usr/bin/echo argocd initial admin password: $(cat /root/argocd_admin_pwd.txt )
  SHELL
end
