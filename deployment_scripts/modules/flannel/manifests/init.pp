# Class: flannel
# ===========================
#
# Full description of class flannel here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'flannel':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
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
class flannel (
  $etcd_servers = 'http://127.0.0.1:2379',
  $net_iface    = 'br-int',
) {

  # TODO: packages
  file { '/usr/bin/flanneld':
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/flanneld",
    tag    => [ 'flanneld', ],
  }

  file { '/etc/init/flanneld.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/flanneld.conf",
    tag    => [ 'flanneld', ],
  }

  file { '/etc/default/flanneld':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/flanneld.erb"),
    tag     => [ 'flanneld', ],
  }

  service { 'flanneld':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }

  File<| tag == 'flanneld' |> ~> Service['flanneld']
}
