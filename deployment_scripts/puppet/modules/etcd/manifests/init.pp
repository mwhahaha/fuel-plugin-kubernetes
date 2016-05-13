# Class: etcd
# ===========================
#
# Full description of class etcd here.
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
#    class { 'etcd':
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
class etcd (
  $node_name               = $::hostname,
  $bind_host               = $::ipaddress,
  $bind_port               = '4001',
  $peer_host               = $::ipaddress,
  $peer_port               = '2380',
  $data_dir                = '/var/etcd/data',
  $bootstrap_cluster       = false,
  $bootstrap_token         = undef,
  $bootstrap_cluster_nodes = undef,
  $bootstrap_cluster_state = undef,
) {

  $etcd_cmd_opts = [
    "--name=${node_name}",
    "--advertise-client-urls=http://${bind_host}:${bind_port}",
    "--listen-client-urls=http://127.0.0.1:${bind_port},http://${bind_host}:${bind_port}",
    "--listen-peer-urls=http://127.0.0.1:${peer_port},http://${peer_host}:${peer_port}",
    "--data-dir=${data_dir}",
  ]

  if $bootstrap_cluster {
    validate_string($bootstrap_token)
    validate_string($bootstrap_cluster_nodes)
    validate_string($bootstrap_cluster_state)
    $etcd_cmd_bootstrap_opts = [
      "--initial-cluster-token=${bootstrap_token}",
      "--initial-cluster=${bootstrap_cluster_nodes}",
      "--initial-cluster-state=${bootstrap_cluster_state}",
      "--initial-advertise-peer-urls=http://${peer_host}:${peer_port}",
    ]
  }

  $etcd_opts = join(concat($etcd_cmd_opts, $etcd_cmd_bootstrap_opts), ' ')

  # TODO: better packages
  package { 'etcd':
    ensure => installed,
    tag    => [ 'etcd', ],
  }

  file { '/etc/init/etcd.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/etcd.conf",
    tag    => [ 'flanneld', ],
  }

  file { '/etc/default/etcd':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/etcd.erb"),
    tag     => [ 'etcd', ],
  }

  file { ['/var/etcd', $data_dir]:
    ensure => directory,
    mode   => '0750',
    owner  => 'root',
    group  => 'root',
    tag    => [ 'etcd', ],
  }

  service { 'etcd':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }

  Package<| tag == 'etcd' |> ->
  File<| tag == 'etcd' |> ~>
  Service['etcd']
}
