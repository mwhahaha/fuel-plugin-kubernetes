# Class: plugin_k8s::kubelet
# ===========================
#
# This class installs and configures kubelet
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
#    include ::plugin_k8s::kubelet
#
class plugin_k8s::kubelet {
  notice('MODULAR: kubernetes/kubelet.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::kubelet':
    bind_address   => $::plugin_k8s::params::bind_address,
    api_servers    => $::plugin_k8s::params::api_vip_url,
    cluster_dns    => $::plugin_k8s::params::dns_server,
    cluster_domain => $::plugin_k8s::params::dns_domain,
    node_name      => $::plugin_k8s::params::node_name,
  }

  firewall { '404 kubelet':
    dport  => [ '10250', '10255', ],
    proto  => 'tcp',
    action => 'accept',
    tag    => [ 'kubernetes', 'kubelet', ],
  }
}
