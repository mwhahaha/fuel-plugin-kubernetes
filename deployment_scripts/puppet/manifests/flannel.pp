notice('MODULAR: kubernetes/flannel.pp')
# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$node = hiera('node')

# get nodes for etcd
$controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-kubernetes-controller', 'kubernetes-controller'])

# get nodes for etcd
$controller_mgmt_nodes = get_node_to_ipaddr_map_by_network_role($controller_nodes, 'management')
$controller_mgmt_ips = ipsort(values($controller_mgmt_nodes))
$etcd_port = '4001'
$etcd_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${etcd_port}")

$tun_int = pick(get_network_role_property('kubernetes', 'interface'), 'br-kubernetes')

class { '::flannel':
  etcd_servers => join($etcd_servers, ','),
  net_iface    => $tun_int,
}->
exec { 'wait-for-flannel':
  path      => ['/bin', '/usr/bin'],
  command   => 'test -f /run/flannel/subnet.env',
  unless    => 'test -f /run/flannel/subnet.env',
  tries     => 10,
  try_sleep => 10,
}
