notice('MODULAR: kubernetes/keepalived.pp')
# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$node = hiera('node')

$controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-kubernetes-controller', 'kubernetes-controller'])

# get controller nodes
$controller_mgmt_nodes = get_node_to_ipaddr_map_by_network_role($controller_nodes, 'management')
$controller_mgmt_ips = ipsort(values($controller_mgmt_nodes))

# TODO: change if the vip is not on the mgmt interface
$mgmt_ip = get_network_role_property('management', 'ipaddr')
$mgmt_int = get_network_role_property('management', 'interface')

$api_secure_port = '6443'
$api_insecure_port = '9999'

$vip_name = 'kube-apiserver'
$api_vip = $network_metadata['vips'][$vip_name]['ipaddr']

$api_port = $api_insecure_port # TODO fix me when ssl

class { '::keepalived':
  service_restart => 'service keepalived restart',
  service_manage  => true,
}

keepalived::vrrp::instance { $vip_name:
  interface         => $mgmt_int,
  state             => 'MASTER',
  virtual_router_id => '50',
  priority          => '100',
  auth_type         => 'PASS',
  auth_pass         => 'asecretpassword!', # TODO: fixme
  virtual_ipaddress => $api_vip,
  unicast_source_ip => $mgmt_ip,
  unicast_peers     => $controller_mgmt_ips,
}

Keepalived::Vrrp::Instance[$vip_name] ~>
  Service[$::keepalived::service_name]
