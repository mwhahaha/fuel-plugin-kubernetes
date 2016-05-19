# Class: calico
# ===========================
#
# Full description of class calico here.
#
# Parameters
# ----------
#
# * `etcd_servers`
# Specify list of etcd_servers.
#
# Examples
# --------
#
# @example
#    class { 'calico':
#      etcd_servers => 'http://127.0.0.1:4001'
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class calico (
  $etcd_servers = 'http://127.0.0.1:2379',
  $cni_conf_dir = '/etc/cni/net.d',
) {

  include ::calico::calicoctl

  class {'::calico::node':
    etcd_servers => $etcd_servers,
  }

  class {'::calico::cni':
    etcd_servers => $etcd_servers,
    confdir      => $cni_conf_dir,
  }

  Class['::calico::calicoctl'] ->
  Class['::calico::node']

}
