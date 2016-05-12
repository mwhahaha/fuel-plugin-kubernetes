notice('MODULAR: kubernetes/scheduler.pp')
# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

# get mgmt ip to bind for etcd
$mgmt_ip = get_network_role_property('management', 'ipaddr')

$vip_name = 'kube-apiserver'
$api_vip = $network_metadata['vips'][$vip_name]['ipaddr']
$api_vip_port = '9990' # TODO fix me when ssl


class { '::kubernetes::scheduler':
  bind_address => $mgmt_ip,
  master_ip    => $api_vip,
  master_port  => $api_vip_port,
}

firewall { '402 scheduler':
  dport  => [ '10251', ],
  proto  => 'tcp',
  action => 'accept',
  tag    => 'kubernetes',
}
