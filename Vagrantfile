# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
sudo apt-get update
sudo apt-get install -y unzip curl wget vim jq tmux python-pip python-dev build-essential libyaml-dev libpython2.7-dev
sudo pip install tmuxp==1.2.1

# Download Consul
export CONSUL_VERSION=0.7.1

echo -e "\e[32mDownloading Consul...\e[0m"
cd /tmp/
curl -sSL "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -o consul.zip

echo Installing consul...
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul

sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d

# Download Nomad
export NOMAD_VERSION=0.5.0

echo -e "\e[32mDownloading Nomad...\e[0m"
cd /tmp/
curl -sSL "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" -o nomad.zip

echo Installing Nomad...
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad

sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d

# Download fabio
export FABIO_VERSION=1.3.5

echo -e "\e[32mDownloading Fabio...\e[0m"
cd /tmp/
curl -sSL "https://github.com/eBay/fabio/releases/download/v$FABIO_VERSION/fabio-$FABIO_VERSION-go1.7.3-linux-amd64" -o fabio

echo Installing Fabio...
sudo chmod +x fabio
sudo mv fabio /usr/bin/fabio

sudo mkdir -p /etc/fabio.d
sudo chmod a+w /etc/fabio.d

cd ~
chmod u+x start.sh
chmod u+x nomad-start.sh
chmod u+x consul-start.sh
chmod u+x fabio-start.sh

SCRIPT

$post_docker_script = <<SCRIPT
echo Configuring DNS resolution...

# The below configuration will get overwritten if `sudo resolvconf -u` is run
# Tried putting it in `/etc/resolvconf/resolv.conf.d/base` but it does not get added at the top
# which results in Consul never being used for DNS queries.
sudo tee /etc/resolv.conf << EOF
nameserver `/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
nameserver 8.8.8.8
search service.consul
EOF

echo Configuring Docker with Consul DNS...
sudo echo "DOCKER_OPTS='--dns `/sbin/ifconfig docker0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'` \
  --dns 8.8.8.8 \
  --dns-search service.consul'" \
  | sudo tee --append /etc/default/docker

echo Restarting Docker for DNS settings...
sudo restart docker

# Only show /etc/motd and nothing else on vagrant ssh
sudo rm /etc/update-motd.d/00-header
sudo rm /etc/update-motd.d/91-release-upgrade
sudo rm /etc/update-motd.d/10-help-text
sudo mv motd /etc/motd
sudo sed -i -e 's/PrintLastLog yes/PrintLastLog no/g' /etc/ssh/sshd_config
sudo restart ssh

echo -e "\e[36mDone \xE2\x9C\x93\e[0m"

SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "puphpet/ubuntu1404-x64"
  config.vm.hostname = "nomad"
  config.vm.provision "file", source: "nomad/vagrant.hcl", destination: "vagrant.hcl"
  config.vm.provision "file", source: "nomad/nomad-start.sh", destination: "nomad-start.sh"
  config.vm.provision "file", source: "consul/consul-start.sh", destination: "consul-start.sh"
  config.vm.provision "file", source: "fabio/fabio-start.sh", destination: "fabio-start.sh"
  config.vm.provision "file", source: "nomad-ui/nomad-ui.nomad", destination: "nomad-ui.nomad"
  config.vm.provision "file", source: "full-hashistack.yml", destination: "full-hashistack.yml"
  config.vm.provision "file", source: "start.sh", destination: "start.sh"
  config.vm.provision "shell", inline: $script, privileged: false, keep_color: true
  # Before we copy to /etc/fabio.d/fabio.properties, it must be created first by $script.
  config.vm.provision "file", source: "fabio/fabio.properties", destination: "/etc/fabio.d/fabio.properties"
  config.vm.provision "docker" # Just install it
  config.vm.provision "file", source: "motd", destination: "motd"
  config.vm.provision "shell", inline: $post_docker_script, privileged: false, keep_color: true

  # Resources and network settings
  $memory = "2048"
  $cpu = 2
  $private_ip = "172.16.0.2"
  $tld = "hashistack.vagrant"

  config.vm.provider "parallels" do |p, o|
    p.memory = $memory
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = $memory
    vb.cpus = $cpu

    if not $linux
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
  end

  ["vmware_fusion", "vmware_workstation"].each do |p|
    config.vm.provider p do |v|
      v.vmx["memsize"] = $memory
    end
  end

  config.landrush.enabled = true
  config.landrush.tld = $tld
  config.landrush.guest_redirect_dns = false
  config.landrush.host_ip_address = $private_ip

  config.vm.hostname = $tld
  config.vm.network "private_network", ip: $private_ip
end
