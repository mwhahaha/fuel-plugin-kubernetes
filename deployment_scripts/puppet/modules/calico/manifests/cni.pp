# Class: calico::cni
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
class calico::cni (
  $etcd_servers   = 'http://127.0.0.1:2379',
  $confdir        = '/etc/cni/net.d',
  $log_level      = 'info',
) {

  package {'calico':
    ensure => installed,
    tag    => ['calico'],
  }

  # TODO: (adidenko) figure out how to specify path to CNI bin
  #       and remove this symlink workaround. Or update package.
  exec {"cni-workaround-dir":
    command => "mkdir -p /opt/cni/bin",
    unless  => "test -d /opt/cni/bin"
  } ->
  file {"/opt/cni/bin/calico":
    ensure => "/usr/bin/calico",
  }

  exec {"create $confdir":
    command => "mkdir -p $confdir",
    unless  => "test -d $confdir",
    path    => [ '/bin', '/usr/bin', '/usr/local/bin'],
  } ->
  file {"$confdir/10-calico.conf":
    ensure  => file,
    content => template("${module_name}/cni.conf.erb"),
    tag     => ['calico'],
  }

  Package<| tag == 'calico' |> ->
  File<| tag == 'calico' |>
}
