# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'.freeze

host_names = %w(manager1 manager2 manager3
                worker1 worker2 worker3)

host_ips = %w(192.168.50.10 192.168.50.11 192.168.50.12
              192.168.50.20 192.168.50.21 192.168.50.22)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/xenial64'

  (0..5).each do |i|
    config.vm.define host_names[i] do |host|
      puts "Host Name: #{host_names[i]}"
      puts "Host IP: #{host_ips[i]}"
      config.vm.provider 'virtualbox' do |vb|
        vb.name = host_names[i]
      end
      host.vm.hostname = host_names[i]
      host.vm.network 'private_network', ip: host_ips[i]
      host.vm.provision 'shell', inline: 'ip addr'
    end

    config.vm.provision 'docker'
  end
end
