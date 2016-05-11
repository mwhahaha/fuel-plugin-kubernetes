# Class: kubernetes::docker::etcd
# ===========================
#
# This class sets up an etcd docker container for kubernetes.
#
# Parameters
# ----------
#
# [*version*]
#  (Optional) Version of the etcd container from gcr.io to use.
#  Defaults to '2.2.1'
#
# [*bind_host*]
#  (Optional) Ip address to bind for etcd.
#  Defaults to '127.0.0.1'
#
# [*bind_port*]
#  (Optional) Port to use for etcd.
#  Defaults to '4001'
#
# [*data_dir*]
#  (Optional) Directory for etcd data within the container.
#  Defaults to '/var/etcd/data'
#
# Variables
# ----------
#
# N/A
#
# Examples
# --------
#
# @example
#    class { 'kubernetes::docker::etcd':
#      data_dir => '/opt/etcd'
#    }
#
# @example
#    class { 'kubernetes::docker::etcd':
#      bootstrap_cluster       => true,
#      bootstrap_token         => 'mytoken',
#      bootstrap_cluster_nodes => 'node1=http://10.0.0.1:2380,node2=http://10.0.0.2:2380,node3=http://10.0.0.3:2380',
#      bootstrap_cluster_state => 'new',
#    }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::docker::etcd (
  $node_name               = $::hostname,
  $version                 = '2.2.1',
  $bind_host               = $::ipaddress,
  $bind_port               = '4001',
  $peer_host               = $::ipaddress,
  $peer_port               = '2380',
  $local_data_dir          = '/srv/etcd',
  $data_dir                = '/var/etcd/data',
  $bootstrap_cluster       = false,
  $bootstrap_token         = undef,
  $bootstrap_cluster_nodes = undef,
  $bootstrap_cluster_state = undef,
) {

  include ::stdlib
  include ::kubernetes::docker

  file { $local_data_dir:
    ensure => directory,
  }

  #TODO(aschultz) check bind/peer hosts are not localhost other wise etcd will
  # not startup.

  $etcd_image = "gcr.io/google_containers/etcd-amd64:${version}"
  $etcd_cmd_opts = [
    '/usr/local/bin/etcd',
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

  $etcd_cmd = join(concat($etcd_cmd_opts, $etcd_cmd_bootstrap_opts), ' ')

  # clustered etcd for kubernetes
  docker::run { 'etcd':
    command          => $etcd_cmd,
    image            => $etcd_image,
    net              => 'host',
    volumes          => [ "${local_data_dir}:${data_dir}:rw", ],
    extra_parameters => ['--restart=always'],
  }
}
