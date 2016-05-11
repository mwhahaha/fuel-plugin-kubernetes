# Class: kubernetes::docker::hyperkube::controller_manager
# ===========================
#
# This class launches the kubernetes docker containers.
#
# Parameters
# ----------
#
# [*master_proto*]
#  (Optional) Protocol to use when talking to the master endpoint
#  Defaults to 'http'
#
# [*master_ip*]
#  (Optional) Ip address of the master endpoint
#  Defaults to '127.0.0.1'
#
# [*master_port*]
#  (Optional) Port for for the master endpoint
#  Defaults to '8080'
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
#    class { 'kubernetes::docker::hyperkube::proxy': }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::docker::hyperkube::controller_manager (
  $bind_address   = '0.0.0.0',
  $cluster_cidr   = '10.246.0.0/16',
  $cluster_name   = 'kubernetes',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
  $resync_period  = '3m',
  $leader_elect   = false, # true for HA (needs kube-system namespace)
) {

  include ::kubernetes::docker::hyperkube

  $proxy_cmd = join([
    '/hyperkube controller-manager',
    "--address=${bind_address}",
    "--cluster-cidr=${cluster_cidr}",
    "--cluster-name=${cluster_name}",
    "--master=${master_ip}:${master_port}",
    "--min-resync-period=${resync_period}",
    "--leader-elect=${leader_elect}",
    '--v=2',
  ], ' ')
  docker::run { 'hyperkube-controller-manager':
    command          => $proxy_cmd,
    image            => $::kubernetes::docker::hyperkube::image,
    net              => 'host',
    extra_parameters => ['--restart=always'],
  }
}
