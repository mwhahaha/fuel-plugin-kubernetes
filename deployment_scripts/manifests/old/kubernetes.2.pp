# docker run \
#    --volume=/:/rootfs:ro \
#    --volume=/sys:/sys:ro \
#    --volume=/var/lib/docker/:/var/lib/docker:rw \
#    --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
#    --volume=/var/run:/var/run:rw \
#    --net=host \
#    --pid=host \
#    --privileged=true \
#    --name=kubelet \
#    -d \
#    gcr.io/google_containers/hyperkube-amd64:${K8S_VERSION} \
#    /hyperkube kubelet \
#        --containerized \
#        --hostname-override="127.0.0.1" \
#        --address="0.0.0.0" \
#        --api-servers=http://localhost:8080 \
#        --config=/etc/kubernetes/manifests \
#        --cluster-dns=10.0.0.10 \
#        --cluster-domain=cluster.local \
#        --allow-privileged=true --v=2
$hyperkube_ver = 'v1.2.3'
docker::run { 'kubelet':
  image            => "gcr.io/google_containers/hyperkube-amd64:${hyperkube_ver}",
  command          => '/hyperkube kubelet --containerized --hostname-override="127.0.0.1" --address="0.0.0.0" --api-servers=http://localhost:8080 --config=/etc/kerbenetes/manifests --cluster-dns=10.0.0.10 --cluster-domain=cluster.local --allow-privileged=true --v=2',
  volumes          => [ '/:/rootfs:ro',
                        '/sys:/sys:ro',
                        '/var/lib/docker/:/var/lib/docker:rw',
                        '/var/lib/kubelet/:/var/lib/kubelet:rw',
                        '/var/run:/var/run:rw', ],
  privileged       => true,
  net              => 'host',
  extra_parameters => [ '--pid=host', ]
}
