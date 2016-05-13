# Class: plugin_k8s::controller_manager
# ===========================
#
# This class installs and configures the kubernetes controller manager
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
#    include ::plugin_k8s::params
#
class plugin_k8s::controller_manager {
  notice('MODULAR: plugin_k8s/controller_manager.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::controller_manager':
    bind_address => $::plugin_k8s::params::bind_address,
    master_ip    => $::plugin_k8s::params::api_vip,
    master_port  => $::plugin_k8s::params::api_vip_port,
    cluster_cidr => $::plugin_k8s::params::cluster_network,
    leader_elect => $::plugin_k8s::params::leader_elect,
  }

  firewall { '403 controller-manager':
    dport  => [ '10252', ],
    proto  => 'tcp',
    action => 'accept',
    tag    => 'kubernetes',
  }
}
