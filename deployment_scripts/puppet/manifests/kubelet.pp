notice('MODULAR: kubernetes/kubelet.pp')
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

# get mgmt ip to bind for etcd
$mgmt_ip = get_network_role_property('management', 'ipaddr')

$api_secure_port = '6443'
$api_insecure_port = '9999'

$api_proto = 'http'
$api_vip = $controller_mgmt_ips[0] # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl
$api_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${api_port}")

$vip_name = 'kube-apiserver'
$api_vip = $network_metadata['vips'][$vip_name]['ipaddr']
$api_vip_port = '9990' # TODO fix me when ssl

$dns_server = hiera('management_vrouter_vip')
$dns_domain = 'test.domain.local' # TODO fix me

class { '::kubernetes::kubelet':
  bind_address   => $mgmt_ip,
  api_servers    => "http://${api_vip}:${api_vip_port}", #NOTE: should this be the api servers instead of the vip?
  cluster_dns    => $dns_server,
  cluster_domain => $dns_domain,
  node_name      => $node['name'],
}

firewall { '404 kubelet':
  dport  => [ '10250', '10255', ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}
