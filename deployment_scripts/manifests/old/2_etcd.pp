# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$node = hiera('node')

# get nodes for etcd
$controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-controller', 'controller'])

# get nodes for etcd
$controller_mgmt_nodes = get_node_to_ipaddr_map_by_network_role($controller_nodes, 'management')
$controller_mgmt_ips = ipsort(values($controller_mgmt_nodes))
$etcd_port = '4001'
$etcd_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${etcd_port}")
$etcd_peer_port = '2380'
$named_etcd_servers = join(suffix(join_keys_to_values($controller_mgmt_nodes,"=http://"), ":${etcd_peer_port}"), ',')

# get mgmt ip to bind for etcd
$mgmt_ip = get_network_role_property('management', 'ipaddr')

class { '::kubernetes::docker': } ->
class { '::kubernetes::docker::etcd':
  name                    => $node['name'],
  bind_host               => $mgmt_ip,
  peer_host               => $mgmt_ip,
  bootstrap_cluster       => true,
  bootstrap_token         => 'fuel-cluster-token',
  bootstrap_cluster_nodes => $named_etcd_servers,
  bootstrap_cluster_state => 'new'
}

firewall { '400 etcd':
  port   => [$etcd_port, $etcd_peer_port],
  proto  => 'tcp',
  action => 'accept',
}
