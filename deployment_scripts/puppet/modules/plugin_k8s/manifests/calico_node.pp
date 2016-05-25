# Class: plugin_k8s::calico_node
# =============================
#
# This class installs and configures calico on minions
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
#    include ::plugin_k8s::calico_node
#
class plugin_k8s::calico_node {
  notice('MODULAR: plugin_k8s/calico_node.pp')

  include ::plugin_k8s::params
  include ::calico::calicoctl

  class { '::calico::node':
    etcd_servers => $::plugin_k8s::params::etcd_servers_list,
  }

  class { '::calico::cni':
    etcd_servers => $::plugin_k8s::params::etcd_servers_list,
    confdir      => $::plugin_k8s::params::network_plugin_dir,
  }

  firewall { '400 bird':
    dport  => [
      $::plugin_k8s::params::bird_port
    ],
    proto  => $::plugin_k8s::params::bird_proto,
    action => 'accept',
    tag    => [ 'kubernetes', 'calico' ]
  }
}
