# Class: plugin_k8s::calico_master
# ================================
#
# This class installs and configures calico on master
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
#    include ::plugin_k8s::calico_master
#
class plugin_k8s::calico_master {
  notice('MODULAR: plugin_k8s/calico_master.pp')

  include ::plugin_k8s::params

  class { '::calico::rcfile':
    etcd_servers => $::plugin_k8s::params::etcd_servers_list,
  }

}
