Vagrant.configure("2") do |config|

  # box:
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # network:
  config.vm.hostname = 'musee' # i've found that setting this is really important
  config.vm.network :private_network, ip: "192.168.56.101" # static IP

  # virtualbox-specific:
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
  end

  # bootstrap file:
  config.vm.provision :shell, :path => "bootstrap.sh"

end

