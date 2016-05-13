# Class: kubernetes::proxy
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
class kubernetes::proxy (
  $master_proto   = 'http',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
) {

  include ::kubernetes::params

  $proxy_opts = join([
    "--master=${master_proto}://${master_ip}:${master_port}",
    '--v=2',
    '--masquerade-all=true',
  ], ' ')

  #TODO(adidenko): better packages
  package { 'kube-proxy':
    ensure => installed,
    tag    => ['proxy',]
  }

  file { '/etc/init/kube-proxy.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/kube-proxy.conf",
    tag    => [ 'proxy', ],
  }

  file { '/etc/default/kube-proxy':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/kube-proxy.erb"),
    tag     => [ 'proxy', ],
  }

  service { 'kube-proxy':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }


  # ensure files are created prior to running the api server
  Package<| tag == 'proxy' |> ->
  File<| tag == 'proxy' |> ~>
  Service['kube-proxy']

}
