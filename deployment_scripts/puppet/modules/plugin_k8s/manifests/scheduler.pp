# Class: plugin_k8s::scheduler
# ===========================
#
# This class installs and configures the kubernetes scheduler
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
#    include ::plugin_k8s::scheduler
#
class plugin_k8s::scheduler {
  notice('MODULAR: plugin_k8s/scheduler.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::scheduler':
    bind_address => $::plugin_k8s::params::bind_address,
    master_ip    => $::plugin_k8s::params::api_vip,
    master_port  => $::plugin_k8s::params::api_vip_port,
    leader_elect => $::plugin_k8s::params::leader_elect,
  }

  firewall { '402 scheduler':
    dport  => [ '10251', ],
    proto  => 'tcp',
    action => 'accept',
    tag    => 'kubernetes',
  }
}
