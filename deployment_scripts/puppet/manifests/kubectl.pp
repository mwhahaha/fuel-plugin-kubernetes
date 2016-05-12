notice('MODULAR: kuberentes/kubectl.pp')

# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$vip_name = 'kube-apiserver'
$api_vip = $network_metadata['vips'][$vip_name]['ipaddr']
$api_vip_port = '9990'

class { '::kubernetes::kubectl': }->
# TODO: make idempotent
exec { 'set-cluster':
  path        => [ '/bin', '/usr/local/bin', ],
  environment => ['HOME=/root'],
  command     => "kubectl config set-cluster fuel --server=http://${api_vip}:${api_vip_port} --insecure-skip-tls-verify=true",
}->
exec { 'set-context':
  path        => [ '/bin', '/usr/local/bin', ],
  environment => ['HOME=/root'],
  command     => 'kubectl config set-context fuel --cluster=fuel'
}->
exec { 'use-context':
  path        => [ '/bin', '/usr/local/bin', ],
  environment => ['HOME=/root'],
  command     => 'kubectl config use-context fuel'
}
