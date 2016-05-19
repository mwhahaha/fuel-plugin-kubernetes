# Class: plugin_k8s::calico
# ===========================
#
# This class installs and configures calico
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
#    include ::plugin_k8s::calico
#
class plugin_k8s::calico {
  notice('MODULAR: plugin_k8s/calico.pp')

  include ::plugin_k8s::params

  class { '::calico':
    etcd_servers => $::plugin_k8s::params::etcd_servers_list,
    cni_conf_dir => $::plugin_k8s::params::network_plugin_dir,
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
