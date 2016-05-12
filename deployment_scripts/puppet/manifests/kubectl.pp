notice('MODULAR: kuberentes/kubectl.pp')

# fuel specific network setup items
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$network_metadata = hiera_hash('network_metadata', {})

$mgmt_ip = get_network_role_property('management', 'ipaddr')
$api_insecure_port = '9999'
$api_vip = $mgmt_ip # TODO fix me with an actual haproxy endpoint
$api_port = $api_insecure_port # TODO fix me when ssl

class { '::kubernetes::kubectl': }->
# TODO: make idempotent
exec { 'set-cluster':
  path        => [ '/bin', '/usr/local/bin', ],
  environment => ['HOME=/root'],
  command     => "kubectl config set-cluster fuel --server=http://${api_vip}:${api_port} --insecure-skip-tls-verify=true",
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
