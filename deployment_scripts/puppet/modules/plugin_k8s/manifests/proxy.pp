# Class: plugin_k8s::proxy
# ===========================
#
# This class installs and configures the kubernetes proxy
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
#    include ::plugin_k8s::proxy
#
class plugin_k8s::proxy {
  notice('MODULAR: plugin_k8s/proxy.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::proxy':
    master_ip   => $::plugin_k8s::params::api_vip,
    master_port => $::plugin_k8s::params::api_vip_port,
  }
}
