notice('MODULAR: kubernetes/apiserver.pp')
# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$node = hiera('node')
$settings = hiera("fuel-plugin-kubernetes", {})

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

# fuel network-group --create --node-group 2 --name kubernetes --release 1 --vlan 1000 --cidr 10.244.0.0/16
$tun_int         = pick(get_network_role_property('kubernetes', 'interface'), 'br-kubernetes')
$tun_network     = pick($settings['internal_net'], '10.246.0.0/16')
$service_network = pick(get_network_role_property('kubernetes', 'network'), '10.244.0.0/16')

$api_secure_port = '6443'
$api_insecure_port = '9999'

$api_vip = $controller_mgmt_ips[0] # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl

class { '::kubernetes::apiserver':
  bind_address          => $mgmt_ip,
  secure_port           => $api_secure_port,
  insecure_bind_address => $mgmt_ip,
  insecure_port         => $api_insecure_port,
  apiserver_count       => size($controller_nodes),
  etcd_servers          => join($etcd_servers, ','),
  service_cluster_ips   => $service_network,
}

firewall { '401 apiserver':
  dport  => [ $api_secure_port, $api_insecure_port, ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}
