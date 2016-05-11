notice('MODULAR: kubernetes/docker.pp')
dns_server = hiera('management_vrouter_vip')

$tun_int = 'br-kubernetes'

# NOTE(aschultz): the flannel facts only exist after flannel is up and gets
# a lease for the network. So basically this won't work right until flannel is
# up and running
class { '::docker':
  bridge  => $tun_int,
  bip     => $::flannel_subnet,
  mtu     => $::flannel_mtu,
  ip_masq => $::flannel_ipmasq,
}
