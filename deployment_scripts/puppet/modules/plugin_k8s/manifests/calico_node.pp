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

  # Kubernetes needs nsenter in order to find out container's IP, nsenter is
  # a part of util-linux starting from version 2.24, so Ubuntu 14.10 and
  # newer are OK
  if $::operatingsystem == 'ubuntu' and $::operatingsystemrelease == '14.04' {
    package {'nsenter':
      ensure => installed,
    }
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
