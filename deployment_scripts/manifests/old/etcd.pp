$etcd_ver = '2.2.1'
$etcd_bind_host = '127.0.0.1'
$etcd_bind_port = '4001'

docker::image { 'etcd':
  image     => 'gcr.io/google_containers/etcd-amd64',
  image_tag => $etcd_ver,
}

# etcd for kubernetes
docker::run { 'etcd':
  image   => "gcr.io/google_containers/etcd-amd64:${etcd_ver}",
  command => "/usr/local/bin/etcd --listen-client-urls=http://${etcd_bind_host}:${etcd_bind_port} --advertise-client-urls=http://${etcd_bind_host}:${etcd_bind_port} --data-dir=/var/etcd/data",
  net     => 'host',
}
