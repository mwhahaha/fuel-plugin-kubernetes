notice('MODULAR: kubernetes/controller_manager.pp')
# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-kubernetes-controller', 'kubernetes-controller'])

if size($controller_nodes) > 1 {
  $leader_elect = true
} else {
  $leader_elect = false
}

$node = hiera('node')

# get mgmt ip to bind for etcd
$mgmt_ip = get_network_role_property('management', 'ipaddr')

$tun_network = '10.246.0.0/16'

$vip_name = 'kube-apiserver'
$api_vip = $network_metadata['vips'][$vip_name]['ipaddr']
$api_vip_port = '9990' # TODO fix me when ssl


class { '::kubernetes::controller_manager':
  bind_address => $mgmt_ip,
  master_ip    => $api_vip,
  master_port  => $api_vip_port,
  cluster_cidr => $tun_network,
  leader_elect => $leader_elect,
}

firewall { '403 controller-manager':
  dport  => [ '10252', ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}
