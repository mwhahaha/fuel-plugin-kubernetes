# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

# get nodes for etcd
$controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-controller', 'controller'])

# get nodes for etcd
$controller_mgmt_nodes = get_node_to_ipaddr_map_by_network_role($controller_nodes, 'management')
$controller_mgmt_ips = ipsort(values($controller_mgmt_nodes))
$etcd_port = '4001'
$etcd_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${etcd_port}")

# get mgmt ip to bind for etcd
$mgmt_ip = get_network_role_property('management', 'ipaddr')

# get nodes for api servers
$api_port = '9999'
$api_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${api_port}")

# primary controller is 'master'
$primary_node = get_nodes_hash_by_roles($network_metadata, ['primary-controller'])
$primary_node_mgmt_ips = values(get_node_to_ipaddr_map_by_network_role($primary_node, 'management'))

class { '::kubernetes::docker': } ->
class { '::kubernetes::docker::etcd':
  bind_host => $mgmt_ip,
}->
class { '::kubernetes::docker::kubernetes':
  master_ip    => $primary_node_mgmt_ips[0],
  master_port  => $api_port,
  api_servers  => join($api_servers, ','),
  etcd_servers => join($etcd_servers, ','),
}->
class { '::kubernetes::kubectl': }
