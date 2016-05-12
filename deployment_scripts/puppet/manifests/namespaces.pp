notice('MODULAR: kuberentes/namespaces.pp')

# the kube-system namespace is needed for HA functions
exec { 'create-kube-system-namespace':
  path        => [ '/bin', '/usr/bin', '/usr/local/bin' ],
  environment => [ 'HOME=/root' ],
  command     => 'kubectl create namespace kube-system',
  unless      => 'kubectl get namespace | grep -q kube-system',
  tries       => 10,
  try_sleep   => 10,
}
