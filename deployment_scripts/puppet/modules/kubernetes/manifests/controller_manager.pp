# Class: kubernetes::controller_manager
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
# Variables
# ----------
#
# N/A
#
# Examples
# --------
#
# @example
#    class { 'kubernetes::docker::hyperkube::proxy': }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::controller_manager (
  $bind_address   = '0.0.0.0',
  $cluster_cidr   = '10.246.0.0/16',
  $cluster_name   = 'kubernetes',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
  $resync_period  = '3m',
  $leader_elect   = false, # true for HA (needs kube-system namespace)
) {

  include ::kubernetes::params

  $controller_manager_opts = join([
    "--address=${bind_address}",
    "--cluster-cidr=${cluster_cidr}",
    "--cluster-name=${cluster_name}",
    "--master=${master_ip}:${master_port}",
    "--min-resync-period=${resync_period}",
    "--leader-elect=${leader_elect}",
    '--v=2',
  ], ' ')

  #TODO(adidenko): better packages
  package { 'kube-controller-manager':
    ensure => installed,
    tag    => ['controller-manager',]
  }

  file { '/etc/init/kube-controller-manager.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/kube-controller-manager.conf",
    tag    => [ 'controller-manager', ],
  }

  file { '/etc/default/kube-controller-manager':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/kube-controller-manager.erb"),
    tag     => [ 'controller-manager', ],
  }

  service { 'kube-controller-manager':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }

  # ensure files are created prior to running the api server
  Package<| tag == 'controller-manager' |> ->
  File<| tag == 'controller-manager' |> ~>
  Service['kube-controller-manager']

}
