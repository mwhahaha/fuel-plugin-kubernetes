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
$mgmt_network = get_network_role_property('management', 'network')

$api_secure_port = '6443'
$api_insecure_port = '9999'

$api_proto = 'http'
$api_vip = $mgmt_ip # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl
$api_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${api_port}")

$dns_server = hiera('management_vrouter_vip')
$dns_domain = 'test.domain.local' # TODO fix me

class { '::kubernetes::docker': } ->
class { '::kubernetes::docker::hyperkube::kubelet':
  bind_address   => $mgmt_ip,
  api_servers    => $api_servers,
  cluster_dns    => $dns_server,
  cluster_domain => $dns_domain,
}

firewall { '404 kubelet':
  port   => [ '10250', '10255', ]
  proto  => 'tcp',
  action => 'accept',
}
