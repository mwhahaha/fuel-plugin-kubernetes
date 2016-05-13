# Class: plugin_k8s::etcd
# ===========================
#
# This class sets up and installs etcd
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
#    include ::plugin_k8s::etcd
#
class plugin_k8s::etcd {
  notice('MODULAR: plugin_k8s/etcd.pp')

  include ::plugin_k8s::params

  class { '::etcd':
    node_name               => $::plugin_k8s::params::node_name,
    bind_host               => $::plugin_k8s::params::bind_address,
    peer_host               => $::plugin_k8s::params::bind_address,
    bootstrap_cluster       => $::plugin_k8s::params::etcd_bootstrap_cluster,
    bootstrap_token         => $::plugin_k8s::params::etcd_bootstrap_token,
    bootstrap_cluster_nodes => $::plugin_k8s::params::etcd_servers_named_list,
    bootstrap_cluster_state => $::plugin_k8s::params::etcd_bootstrap_cluster_state,
  } ->
  # TODO(aschultz): etcdctl and make idempotent
  exec { 'set-flannel-netconfig':
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    command   => "curl http://${::plugin_k8s::params::bind_address}:${::plugin_k8s::params::etcd_port}/v2/keys/coreos.com/network/config -XPUT -d value=\"{\\\"Network\\\": \\\"${::plugin_k8s::params::cluster_network}\\\", \\\"SubnetLen\\\": 24,\\\"Backend\\\": { \\\"Type\\\": \\\"${::plugin_k8s::params::flannel_type}\\\", \\\"Port\\\": ${::plugin_k8s::params::flannel_port} }}\"",
    tries     => 10,
    try_sleep => 10,
  }

  firewall { '400 etcd':
    dport  => [
      $::plugin_k8s::params::etcd_port,
      $::plugin_k8s::params::etcd_peer_port
    ],
    proto  => 'tcp',
    action => 'accept',
    tag    => [ 'kubernetes', 'etcd', ]
  }
}
