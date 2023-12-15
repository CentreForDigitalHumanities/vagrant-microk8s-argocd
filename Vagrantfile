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
  config.vm.provision "file", source: "#{File.dirname(__FILE__)}/.bash_aliases", destination: "~/.bash_aliases"
  # microk8s install and provision
  config.vm.provision :shell, path: "#{File.dirname(__FILE__)}/bin/bootstrap.sh"
end
