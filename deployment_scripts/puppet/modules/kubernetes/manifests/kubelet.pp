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
# [*network_plugin*]
#  (Optional) Network plugin for kubelet
#
# [*network_plugin_dir*]
#  (Optional) Network plugin directory for kubelet
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
  $master_proto         = 'http',
  $master_ip            = '127.0.0.1',
  $master_port          = '8080',
  $bind_address         = '0.0.0.0',
  $cluster_dns          = '10.0.0.10',
  $cluster_domain       = 'cluster.local',
  $api_servers          = 'http://127.0.0.1:8080',
  $etcd_servers         = 'http://127.0.0.1:4001',
  $config_dir           = '/srv/kubernetes-config',
  $node_name            = $::ipaddress,
  $idle_timeout         = '1h0m0s',
  $sync_frequency       = '1m0s',
  $http_check_frequency = '20s',
  $network_plugin       = undef,
  $network_plugin_dir   = undef,
) inherits ::kubernetes::params {

  file { $config_dir:
    ensure => directory,
    owner  => $::kubernetes::params::kubernetes_owner,
    group  => $::kubernetes::params::kubernetes_group,
    tag    => ['kubelet'],
  }

  # TODO(aschultz): hostname-override is here to prevent kubelet failing if
  # it cannot lookup the hostname. This should probably be removed/figured out
  $default_opts = [
    '--configure-cbr0=false', # fuel handles bridges for ovs
    "--hostname-override=${node_name}", # FIXME
    "--address=${bind_address}",
    "--api-servers=${api_servers}",
    "--config=${config_dir}",
    "--cluster-dns=${cluster_dns}",
    "--cluster-domain=${cluster_domain}",
    "--streaming-connection-idle-timeout=${idle_timeout}",
    "--sync-frequency=${sync_frequency}",
    "--http-check-frequency=${http_check_frequency}",
    '--allow-privileged=true',
    '--v=2',
  ]

  if $network_plugin {
    $additional_opts = [
      "--network-plugin=${network_plugin}",
      "--network-plugin-dir=${network_plugin_dir}"
    ]
  } else {
    $additional_opts = []
  }

  $kubelet_opts = join(concat($default_opts, $additional_opts), ' ')

  #TODO(adidenko): better packages
  package { 'kubelet':
    ensure => installed,
    tag    => ['kubelet',]
  }

  file { '/etc/init/kubelet.conf':
    ensure => present,
    mode   => '0644',
    owner  => $::kubernetes::params::kubernetes_owner,
    group  => $::kubernetes::params::kubernetes_group,
    source => "puppet:///modules/${module_name}/kubelet.conf",
    tag    => [ 'kubelet', ],
  }

  file { '/etc/default/kubelet':
    ensure  => present,
    mode    => '0644',
    owner   => $::kubernetes::params::kubernetes_owner,
    group   => $::kubernetes::params::kubernetes_group,
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
  Package<| tag == 'kubelet' |> ->
  File<| tag == 'kubelet' |> ~>
  Service['kubelet']
}
