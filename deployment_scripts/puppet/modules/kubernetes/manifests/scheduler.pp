# Class: kubernetes::scheduler
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
#    class { 'kubernetes::scheduler': }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::scheduler (
  $bind_address   = '0.0.0.0',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
  $scheduler_name = 'default-scheduler',
  $leader_elect   = false, # true for HA (needs kube-system namespace)
) {

  include ::kubernetes::params

  $scheduler_opts = join([
    "--address=${bind_address}",
    "--master=${master_ip}:${master_port}",
    "--scheduler-name=${scheduler_name}",
    "--leader-elect=${leader_elect}",
    '--v=2',
  ], ' ')

  #TODO(adidenko): better packages
  package { 'kube-scheduler':
    ensure => installed,
    tag    => ['scheduler',]
  }

  file { '/etc/init/kube-scheduler.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/kube-scheduler.conf",
    tag    => [ 'scheduler', ],
  }

  file { '/etc/default/kube-scheduler':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/kube-scheduler.erb"),
    tag     => [ 'scheduler', ],
  }

  service { 'kube-scheduler':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }

  # ensure files are created prior to running the api server
  Package<| tag == 'scheduler' |> ->
  File<| tag == 'scheduler' |> ~>
  Service['kube-scheduler']

}
