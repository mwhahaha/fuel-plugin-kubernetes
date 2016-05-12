# Class: kubernetes::kubelet
# ===========================
#
# This class launches the kubernetes docker containers.
#
# Parameters
# ----------
#
# [*master_proto*]
#  (Optional) Protocol to use when talking to the master endpoint
#  Defaults to 'http'
#
# [*master_ip*]
#  (Optional) Ip address of the master endpoint
#  Defaults to '127.0.0.1'
#
# [*master_port*]
#  (Optional) Port for for the master endpoint
#  Defaults to '8080'
#
# [*bind_address*]
#  (Optional) Address to bind to
#  Defaults to '0.0.0.0'
#
# [*cluster_dns*]
# [*cluster_domain*]
#
# [*config_dir*]
#  (Optional) Directory for kuberenetes pods configurations as used by
#  kubelet. This directory needs to exist on both the docker host system
#  and will be mounted rw in the kubelet docker container.
#  Defaults to '/srv/kubernetes-config'
#
# Variables
# ----------
#
# N/A
#
# Examples
# --------
#
# @example
#    class { 'kubernetes::docker::kubernetes':
#      hyperkube_ver => 'v1.2.0'
#    }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::kubelet (
  $master_proto   = 'http',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
  $bind_address   = '0.0.0.0',
  $cluster_dns    = '10.0.0.10',
  $cluster_domain = 'cluster.local',
  $api_servers    = 'http://127.0.0.1:8080',
  $etcd_servers   = 'http://127.0.0.1:4001',
  $config_dir     = '/srv/kubernetes-config',
  $node_name      = $::ipaddress,
) {

  include ::kubernetes::params

  file { $config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    tag    => ['kubelet'],
  }

#  # master kubernets pods configuration
#  file { "${config_dir}/master.json":
#    ensure  => file,
#    owner   => 'root',
#    group   => 'root',
#    content => template("${module_name}/master.json.erb"),
#    tag     => ['kubernetes-config'],
#  }

  # TODO(aschultz): hostname-override is here to prevent kubelet failing if
  # it cannot lookup the hostname. This should probably be removed/figured out
  $kubelet_opts = join([
    '--configure-cbr0=false', # fuel handles bridges for ovs
    "--hostname-override=${node_name}", # FIXME
    "--address=${bind_address}",
    "--api-servers=${api_servers}",
    "--config=${config_dir}",
    "--cluster-dns=${cluster_dns}",
    "--cluster-domain=${cluster_domain}",
    '--allow-privileged=true',
    '--v=2',
  ], ' ')

  file { '/usr/bin/kubelet':
    ensure => present,
    mode   => '0755',
    source => "${::kubernetes::params::version_file_source}/kubelet",
    owner  => 'root',
    group  => 'root',
    tag    => ['kubelet',]
  }

  file { '/etc/init/kubelet.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/kubelet.conf",
    tag    => [ 'kubelet', ],
  }

  file { '/etc/default/kubelet':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/kubelet.erb"),
    tag     => [ 'kubelet', ],
  }

  service { 'kubelet':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }

  # makes sure kubernetes pods configs are put inplace before starting the
  # kubelet container
  File<| tag == 'kubelet' |> ~> Service['kubelet']
}
