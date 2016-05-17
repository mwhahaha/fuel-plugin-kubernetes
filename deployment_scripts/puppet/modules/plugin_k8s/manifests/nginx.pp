# Class: plugin_k8s::nginx
# ===========================
#
# This class configures nginx as our vip loadbalancer infront of the api servers
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
#    include ::plugin_k8s::nginx
#
class plugin_k8s::nginx {
  notice('MODULAR: plugin_k8s/nginx.pp')

  include ::plugin_k8s::params

  sysctl::value { 'net.ipv4.ip_nonlocal_bind':
    value => '1'
  }

  class { '::nginx': }

  nginx::resource::upstream { $::plugin_k8s::params::vip_name:
    members => $::plugin_k8s::params::api_nodes,
  }

  # we set a high proxy read timeout because the api server and the clients use
  # very long lived watcher connections
  nginx::resource::vhost { $::plugin_k8s::params::vip_name:
    listen_ip          => $::plugin_k8s::params::api_vip,
    listen_port        => $::plugin_k8s::params::api_vip_port,
    proxy              => "${::plugin_k8s::params::api_proto}://${::plugin_k8s::params::vip_name}",
    proxy_read_timeout => '1800',
  }

  firewall { '401 apiserver vip':
    dport  => [ $::plugin_k8s::params::api_vip_port, ],
    proto  => 'tcp',
    action => 'accept',
    tag    => 'kubernetes',
  }

  Sysctl::Value['net.ipv4.ip_nonlocal_bind'] ->
    Service['nginx']
}
