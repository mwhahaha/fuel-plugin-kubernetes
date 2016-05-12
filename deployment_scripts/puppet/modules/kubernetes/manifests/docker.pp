# Class: kubernetes::docker
# ===========================
#
# This class will setup docker for kubernetes.
#
# Parameters
# ----------
#
# N/A
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
#    class { 'kubernetes::docker': }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::docker (
  $bridge = 'br-mgmt',
  $bip    = undef,
  $mtu    = undef,
) {

  class { '::docker':
    #tcp_bind        => ['tcp://127.0.0.1:4243','tcp://10.0.0.1:4243'],
    #socket_bind     => 'unix:///var/run/docker.sock',
    #ip_forward      => true,
    #iptables        => true,
    #ip_masq         => true,
    #bridge          => br0,
    #fixed_cidr      => '10.20.1.0/24',
    #default_gateway => '10.20.0.1',
    #dns             => ['8.8.8.8', '8.8.4.4'],
    #ip_forward      => true,
    #iptables        => false,
    #ip_masq         => false,
    #bridge          => $bridge,
    bip              => $bip,
    mtu              => $mtu,
  }
}
