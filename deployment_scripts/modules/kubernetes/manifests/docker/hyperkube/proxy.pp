# Class: kubernetes::docker::hyperkube::proxy
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
class kubernetes::docker::hyperkube::proxy (
  $master_proto   = 'http',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
) {

  include ::kubernetes::docker::hyperkube

  $proxy_cmd = join([
    '/hyperkube proxy',
    "--master=${master_proto}://${master_ip}:${master_port}",
    '--v=2',
    '--masquerade-all=true',
  ], ' ')

  docker::run { 'hyperkube-proxy':
    command          => $proxy_cmd,
    image            => $::kubernetes::docker::hyperkube::image,
    net              => 'host',
    privileged       => true,
    extra_parameters => [ '--restart=always' ],
  }
}
