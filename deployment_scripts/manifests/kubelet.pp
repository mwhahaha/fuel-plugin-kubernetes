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
#$tun_network = get_network_role_property('neutron/mesh', 'network')
#$tun_int = get_network_role_property('neutron/mesh', 'interface')
# fuel network-group --create --node-group 2 --name kubernetes --release 1 --vlan 1000 --cidr 10.244.0.0/16
$tun_network = '10.244.0.0/16'
$tun_int = 'br-kubernetes'
$service_network = '172.12.0.0/24'

$api_secure_port = '6443'
$api_insecure_port = '9999'

$api_proto = 'http'
$api_vip = $controller_mgmt_ips[0] # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl
$api_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${api_port}")

$dns_server = hiera('management_vrouter_vip')
$dns_domain = 'test.domain.local' # TODO fix me

class { '::kubernetes::docker':
  bridge => $tun_int,
}
class { '::kubernetes::docker::hyperkube::proxy':
  master_ip   => $api_vip,
  master_port => $api_port,
}
class { '::kubernetes::docker::hyperkube::kubelet':
  bind_address   => $mgmt_ip,
  api_servers    => $api_servers, #TODO can this be the vip?
  cluster_dns    => $dns_server,
  cluster_domain => $dns_domain,
  node_name      => $node['name'],
}

exec { 'add service network route':
  path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
  command => "ip route add ${service_network} dev ${tun_int}",
  unless  => "ip route list ${service_network} | grep -q ${tun_int}"
}

firewall { '404 kubelet':
  dport  => [ '10250', '10255', ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}
