# Class: plugin_k8s::apiserver
# ===========================
#
# This class is our task to setup and install the kubernetes api server.
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
#    include ::plugin_k8s::apiserver
#
class plugin_k8s::apiserver {
  notice('MODULAR: plugin_k8s/apiserver.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::apiserver':
    bind_address          => $::plugin_k8s::params::bind_address,
    secure_port           => $::plugin_k8s::params::api_secure_port,
    insecure_bind_address => $::plugin_k8s::params::bind_address,
    insecure_port         => $::plugin_k8s::params::api_insecure_port,
    apiserver_count       => $::plugin_k8s::params::api_server_count,
    etcd_servers          => $::plugin_k8s::params::etcd_servers_list,
    service_cluster_ips   => $::plugin_k8s::params::service_network,
  }

  firewall { '401 apiserver':
    dport  => [
      $::plugin_k8s::params::api_secure_port,
      $::plugin_k8s::params::api_insecure_port,
    ],
    proto  => 'tcp',
    action => 'accept',
    tag    => 'kubernetes',
  }
}
