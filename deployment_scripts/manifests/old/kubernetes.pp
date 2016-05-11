$hyperkube_ver  = 'v1.2.3'
$master_proto   = 'http'
$master_ip      = '127.0.0.1'
$master_port    = '8080'
$bind_address   = '0.0.0.0'
$cluster_dns    = '10.0.0.10'
$cluster_domain = 'cluster.local'

#docker::image { 'hyperkube':
#  image     => 'gcr.io/google_containers/hyperkube-amd64',
#  image_tag => $hyperkube_ver,
#}

file { '/srv/kubernetes-config':
  ensure => directory,
}

Docker::Run {
  image   => "gcr.io/google_containers/hyperkube-amd64:${hyperkube_ver}",
  net     => 'host'
}

docker::run { 'hyperkube-proxy':
  command    => "/hyperkube proxy --master=${master_proto}://${master_ip}:${master_port} --v=2 --resource-container=\"\"",
  privileged => true,
}

docker::run { 'hyperkube-kubelet':
  command          => "/hyperkube kubelet --containerized --hostname-override=${master_ip} --address=${bind_address} --api-servers=${master_proto}://${master_ip}:${master_port} --config=/srv/kubernetes-config --cluster-dns=${cluster_dns} --cluster-domain=${cluster_domain} --allow-privileged=true --v=2",
  volumes          => [ '/:/rootfs:ro',
                        '/sys:/sys:ro',
                        '/var/lib/docker/:/var/lib/docker:rw',
                        '/var/lib/kubelet/:/var/lib/kubelet:rw',
                        '/var/run:/var/run:rw',
                        '/srv/kubernetes-config:/srv/kubernetes-config:rw' ],
  privileged       => true,
  net              => 'host',
  extra_parameters => [ '--pid=host', ]
}
