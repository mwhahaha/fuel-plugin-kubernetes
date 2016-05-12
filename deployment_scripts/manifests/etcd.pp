notice('MODULAR: kubernetes/etcd.pp')
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
$etcd_peer_port = '2380'
$named_etcd_servers = join(suffix(join_keys_to_values($controller_mgmt_nodes,"=http://"), ":${etcd_peer_port}"), ',')

# get mgmt ip to bind for etcd
$mgmt_ip = get_network_role_property('management', 'ipaddr')
$mgmt_network = get_network_role_property('management', 'network')
#$tun_network = get_network_role_property('neutron/mesh', 'network')
#$tun_int = get_network_role_property('neutron/mesh', 'interface')
# fuel network-group --create --node-group 2 --name kubernetes --release 1 --vlan 1000 --cidr 10.244.0.0/16
$tun_network = "10.246.0.0/16"
$tun_int = 'br-kubernetes'
$service_network = '10.244.0.0/16'

$api_secure_port = '6443'
$api_insecure_port = '9999'

$api_vip = $controller_mgmt_ips[0] # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl


class { '::etcd':
  node_name               => $node['name'],
  bind_host               => $mgmt_ip,
  peer_host               => $mgmt_ip,
  bootstrap_cluster       => true,
  bootstrap_token         => 'fuel-cluster-token',
  bootstrap_cluster_nodes => $named_etcd_servers,
  bootstrap_cluster_state => 'new'
} ->
# TODO(aschultz): etcdctl
exec { 'set-flannel-netconfig':
  path        => [ '/bin', '/usr/bin', '/usr/local/bin' ],
  command     => "curl http://${mgmt_ip}:${etcd_port}/v2/keys/coreos.com/network/config -XPUT -d value=\"{\\\"Network\\\": \\\"${tun_network}\\\", \\\"SubnetLen\\\": 24,\\\"Backend\\\": { \\\"Type\\\": \\\"udp\\\", \\\"Port\\\": 8285 }}\"",
  tries => 10,
  try_sleep => 10,
}

firewall { '400 etcd':
  dport  => [ $etcd_port, $etcd_peer_port ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}
