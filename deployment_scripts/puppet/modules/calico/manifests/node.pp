# Class: calico::node
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
class calico::node (
  $etcd_servers   = 'http://127.0.0.1:2379',
) {

  # Setup node
  exec {'setup-calico-node':
    command     => 'calicoctl node',
    environment => "ETCD_ENDPOINTS=$etcd_servers",
    unless      => "calicoctl node show | grep ' $::fqdn '",
    tag         => ['calico'],
    # it's going to pull calico/node container, which may
    # take some time
    timeout     => 900,
    tries       => 2,
  }

  #TODO: (adidenko) configure service

  Exec<||> {
     path => [ '/bin', '/usr/bin', '/usr/local/bin'],
  }
}
