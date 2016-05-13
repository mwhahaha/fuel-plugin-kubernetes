# Class: plugin_k8s::docker
# ===========================
#
# This class is our task to setup and install docker with the correct config
# from flannel
#
# Parameters
# ----------
#
#
# Variables
# ----------
#
#
# Examples
# --------
#
# @example
#    include ::plugin_k8s::docker
#
class plugin_k8s::docker {
  notice('MODULAR: plugin_k8s/docker.pp')

  include ::plugin_k8s::params

  # NOTE(aschultz): the flannel facts only exist after flannel is up and gets
  # a lease for the network. So basically this won't work right until flannel is
  # up and running
  # http://www.slideshare.net/lorispack/using-coreos-flannel-for-docker-networking
  class { '::docker':
    bip     => $::flannel_subnet,
    mtu     => $::flannel_mtu,
    ip_masq => str2bool($::flannel_ipmasq),
  }
}
