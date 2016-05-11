# Class: kubernetes::docker::hyperkube::scheduler
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
class kubernetes::docker::hyperkube::scheduler (
  $bind_address   = '0.0.0.0',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
  $scheduler_name = 'default-scheduler',
  $leader_elect   = false, # true for HA (needs kube-system namespace)
) {

  include ::kubernetes::docker::hyperkube

  # defaults for the runs
  Docker::Run {
    image      => $::kubernetes::docker::hyperkube::image,
    net        => 'host',
    privileged => true,
  }

  $scheduler_cmd = join([
    '/hyperkube scheduler',
    "--address=${bind_address}",
    "--master=${master_ip}:${master_port}",
    "--scheduler-name=${scheduler_name}",
    "--leader-elect=${leader_elect}",
    '--v=2',
  ], ' ')
  docker::run { 'hyperkube-scheduler':
    command          => $scheduler_cmd,
    image            => $::kubernetes::docker::hyperkube::image,
    net              => 'host',
    extra_parameters => [ '--restart=always' ],
  }
}
