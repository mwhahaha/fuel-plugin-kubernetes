notice('MODULAR: kubernetes/nginx.pp')
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
$api_vip_port = '9990'
$api_nodes = suffix($controller_mgmt_ips, ":${api_insecure_port}")

$api_port = $api_insecure_port # TODO fix me when ssl

sysctl::value { 'net.ipv4.ip_nonlocal_bind':
  value => '1'
}

class { 'nginx': }

nginx::resource::upstream { $vip_name:
  members => $api_nodes,
}

nginx::resource::vhost { $vip_name:
  listen_ip   => $api_vip,
  listen_port => $api_vip_port,
  proxy       => "http://${vip_name}",
}

firewall { '401 apiserver vip':
  dport  => [ $api_vip_port, ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}


Sysctl::Value['net.ipv4.ip_nonlocal_bind'] ->
  Service['nginx']
