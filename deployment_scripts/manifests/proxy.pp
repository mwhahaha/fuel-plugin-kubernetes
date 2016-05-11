notice('MODULAR: kubernetes/proxy.pp')
# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

# get nodes for etcd
$controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-kubernetes-controller', 'kubernetes-controller'])

# get nodes for etcd
$controller_mgmt_nodes = get_node_to_ipaddr_map_by_network_role($controller_nodes, 'management')
$controller_mgmt_ips = ipsort(values($controller_mgmt_nodes))

$api_secure_port = '6443'
$api_insecure_port = '9999'

$api_proto = 'http'
$api_vip = $controller_mgmt_ips[0] # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl

class { '::kubernetes::proxy':
  master_ip   => $api_vip,
  master_port => $api_port,
}

