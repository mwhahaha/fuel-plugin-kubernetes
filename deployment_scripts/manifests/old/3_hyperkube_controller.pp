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

$api_vip = $mgmt_ip # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl


class { '::kubernetes::docker': } ->
class { '::kubernetes::docker::hyperkube::apiserver':
  bind_address          => $mgmt_ip,
  secure_port           => $api_secure_port,
  insecure_bind_address => $mgmt_ip,
  insecure_port         => $api_insecure_port,
  apiserver_count       => size($controller_nodes),
  etcd_servers          => join($etcd_servers, ','),
  service_cluster_ips   => $mgmt_network,
}->
class { '::kubernetes::docker::hyperkube::proxy':
  master_ip   => $api_ip,
  master_port => $api_port,
}->
class { '::kubernetes::docker::hyperkube::scheduler':
  bind_address => $mgmt_ip,
  master_ip    => $api_ip,
  master_port  => $api_port,
}->
class { '::kubernetes::docker::hyperkube::controller_manager':
  bind_address => $mgmt_ip,
  master_ip    => $api_ip,
  master_port  => $api_port,
}

firewall { '401 apiserver':
  port   => [$api_secure_port, $api_insecure_port, ]
  proto  => 'tcp',
  action => 'accept',
}

firewall { '402 scheduler':
  port   => ['10251',]
  proto  => 'tcp',
  action => 'accept',
}
firewall { '403 controller-manager':
  port   => ['10252',]
  proto  => 'tcp',
  action => 'accept',
}
