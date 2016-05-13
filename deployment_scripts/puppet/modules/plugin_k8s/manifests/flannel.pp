# Class: plugin_k8s::flannel
# ===========================
#
# This class installs and configures flannel
#
# Parameters
# ----------
#
#
# Variables
# ----------
#
#
# Examples
# --------
#
# @example
#    include ::plugin_k8s::flannel
#
class plugin_k8s::flannel {
  notice('MODULAR: plugin_k8s/flannel.pp')

  include ::plugin_k8s::params

  class { '::flannel':
    etcd_servers => $::plugin_k8s::params::etcd_servers_list,
    net_iface    => $::plugin_k8s::params::cluster_interface,
  }->
  exec { 'wait-for-flannel':
    path      => ['/bin', '/usr/bin'],
    command   => 'test -f /run/flannel/subnet.env',
    unless    => 'test -f /run/flannel/subnet.env',
    tries     => 10,
    try_sleep => 10,
  }

  firewall { '400 etcd':
    dport  => [
      $::plugin_k8s::params::flannel_port
    ],
    proto  => $::plugin_k8s::params::flannel_proto,
    action => 'accept',
    tag    => [ 'kubernetes', 'flannel' ]
  }
}
