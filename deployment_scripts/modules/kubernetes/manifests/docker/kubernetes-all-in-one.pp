$hyperkube_ver = 'v1.2.3'
$master_proto = 'http'
$master_ip = '127.0.0.1'
$master_port = '8080'
$bind_address = '0.0.0.0'
$cluster_dns = '10.0.0.10'
$cluster_domain = 'cluster.local'

docker::image { 'hyperkube':
  image     => 'gcr.io/google_containers/hyperkube-amd64',
  image_tag => $hyperkube_ver,
}

Docker::Run {
  image   => "gcr.io/google_containers/hyperkube-amd64:${hyperkube_ver}",
  net     => 'host'
}

#docker::run { 'hyperkube-scheduler':
#  ensure  => absent,
#  command => "/hyperkube scheduler --master=${master_ip}:${master_port} --v=2",
#}
#
#docker::run { 'hyperkube-proxy':
#  ensure  => absent,
#  command => "/hyperkube proxy --master=${master_proto}://${master_ip}:${master_port} --v=2 --resource-container=\"\"",
#}

#export K8S_VERSION=$(curl -sS https://storage.googleapis.com/kubernetes-release/release/stable.txt)
#docker run \
#  --volume=/:/rootfs:ro \
#  --volume=/sys:/sys:ro \
#  --volume=/var/lib/docker/:/var/lib/docker:rw \
#  --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
#  --volume=/var/run:/var/run:rw \
#  --net=host \
#  --pid=host \
#  --privileged=true \
#  --name=kubelet \
#  -d \
#  gcr.io/google_containers/hyperkube-amd64:${K8S_VERSION} \
#  /hyperkube kubelet \
#  --containerized \
#  --hostname-override="127.0.0.1" \
#  --address="0.0.0.0" \
#  --api-servers=http://localhost:8080 \
#  --config=/etc/kubernetes/manifests \
#  --cluster-dns=10.0.0.10 \
#  --cluster-domain=cluster.local \
#  --allow-privileged=true --v=2
#

docker::run { 'hyperkube-kubelet':
  command          => "/hyperkube kubelet --containerized --hostname-override=${master_ip} --address=${bind_address} --api-servers=${master_proto}://${master_ip}:${master_port} --config=/etc/kubernetes/manifests --cluster-dns=${cluster_dns} --cluster-domain=${cluster_domain} --allow-privileged=true --v=2",
  volumes          => [ '/:/rootfs:ro',
                        '/sys:/sys:ro',
                        '/var/lib/docker/:/var/lib/docker:rw',
                        '/var/lib/kubelet/:/var/lib/kubelet:rw',
                        '/var/run:/var/run:rw', ],
  privileged       => true,
  net              => 'host',
  extra_parameters => [ '--pid=host', ]
}
