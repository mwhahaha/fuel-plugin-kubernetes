# Class: calico::calicoctl
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
class calico::calicoctl (
  $etcd_servers = 'http://127.0.0.1:2379',
) {
  package {'calicoctl':
    ensure => installed,
    tag    => ['calico'],
  }
}
