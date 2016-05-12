notice('MODULAR: kubernetes/docker.pp')

# NOTE(aschultz): the flannel facts only exist after flannel is up and gets
# a lease for the network. So basically this won't work right until flannel is
# up and running
# http://www.slideshare.net/lorispack/using-coreos-flannel-for-docker-networking
class { '::docker':
  bip     => $::flannel_subnet,
  mtu     => $::flannel_mtu,
  ip_masq => str2bool($::flannel_ipmasq),
}
