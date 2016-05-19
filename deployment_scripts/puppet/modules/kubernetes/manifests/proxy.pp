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
# [*proxy_mode*]
#  (Optional) Proxy mode
#  Defaults to 'undef'
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
  $proxy_mode     = undef,
) {

  include ::kubernetes::params

  $default_opts = [
    "--master=${master_proto}://${master_ip}:${master_port}",
    '--v=2',
    '--masquerade-all=true',
  ]

  if $proxy_mode {
    $additional_opts = ["--proxy-mode=$proxy_mode"]
  } else {
    $additional_opts = []
  }

  $proxy_opts = join(concat($default_opts, $additional_opts), ' ')

  #TODO(adidenko): better packages
  package { 'kube-proxy':
    ensure => installed,
    tag    => ['proxy',]
  }

  file { '/etc/init/kube-proxy.conf':
    ensure => present,
    mode   => '0644',
    owner  => $::kubernetes::params::kubernetes_owner,
    group  => $::kubernetes::params::kubernetes_group,
    source => "puppet:///modules/${module_name}/kube-proxy.conf",
    tag    => [ 'proxy', ],
  }

  file { '/etc/default/kube-proxy':
    ensure  => present,
    mode    => '0644',
    owner   => $::kubernetes::params::kubernetes_owner,
    group   => $::kubernetes::params::kubernetes_group,
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
