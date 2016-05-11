# Class: kubernetes::docker::hyperkube::apiserver
# ===========================
#
# This class launches the kubernetes docker containers.
#
# Parameters
# ----------
#
# [*master_proto*]
#  (Optional) Protocol to use when talking to the master endpoint
#  Defaults to 'http'
#
# Variables
# ----------
#
# N/A
#
# Examples
# --------
#
# @example
#    class { 'kubernetes::docker::kubernetes':
#      hyperkube_ver => 'v1.2.0'
#    }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::docker::hyperkube::apiserver (
  $bind_address           = '0.0.0.0',
  $secure_port            = '6443',
  $insecure_bind_address  = '0.0.0.0',
  $insecure_port          = '8080',
  $apiserver_count        = 1,
  $etcd_servers           = 'http://127.0.0.1:4001',
  $service_cluster_ips    = '10.0.0.1/24',
  $apiserver_dir          = '/srv/kubernetes',
) {

  include ::kubernetes::docker::hyperkube

  ensure_resource('file', [$apiserver_dir], {
    ensure => 'directory',
    tag    => 'hyperkube-apiserver',
  })
  ensure_resource('file', ["${apiserver_dir}/basic_auth.csv"], {
    ensure  => 'file',
    content => 'admin,admin,admin',
    tag     => 'hyperkube-apiserver-config',
  })
  #TODO: generate these
  $known_tokens=join([
    'BA3h9DoCxlDQNXCNCLfLkFhWdZg1NyOh,admin,admin',
    'I99YSNPyV7FKEhfN3tTo8M6LpbUSXYOH,kubelet,kubelet',
    'qxfg5oj3wvhr8kUZgdanmJ1I0rVFq6lo,kube_proxy,kube_proxy',
  ], "\n")
  ensure_resource('file', ["${apiserver_dir}/known_tokens.csv"], {
    ensure  => 'file',
    content => $known_tokens,
    tag     => 'hyperkube-apiserver-config',
  })

  $apiserver_cmd = join([
    '/hyperkube apiserver',
    "--apiserver-count=${apiserver_count}",
    "--bind-address=${bind_address}", # TODO: fix ssl
    "--secure-port=${secure_port}",
    "--insecure-bind-address=${insecure_bind_address}",
    "--insecure-port=${insecure_port}",
    "--service-cluster-ip-range=${service_cluster_ips}",
    "--etcd-servers=${etcd_servers}",
    # https://github.com/kubernetes/kubernetes/issues/11222 & https://github.com/kubernetes/kubernetes/issues/12991
    #'--admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota', # FIXME: ServiceAccount -> only works with certs for auth
    '--admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ResourceQuota',
    '--min-request-timeout=300',
    #"--client-ca-file=/srv/kubernetes/ca.crt",
    #"--tls-cert-file=//server.cert",
    #"--tls-private-key-file=${apiserver_dir}/server.key",
    "--basic-auth-file=${apiserver_dir}/basic_auth.csv",
    "--token-auth-file=${apiserver_dir}/known_tokens.csv",
    '--allow-privileged=true',
    '--v=2',
  ], ' ')

  docker::run { 'hyperkube-apiserver':
    command          => $apiserver_cmd,
    image            => $::kubernetes::docker::hyperkube::image,
    net              => 'host',
    volumes          => [
      "${apiserver_dir}:${apiserver_dir}:rw",
    ],
    extra_parameters => ['--restart=always'],
  }

  # ensure files are created prior to running the api server
  File<| tag == 'hyperkube-apiserver-config' |> ~>
    Docker::Run['hyperkube-apiserver']

  # TODO(aschultz): for HA we need to create a kube-system namespace
  # see https://github.com/kubernetes/kubernetes/blob/master/cluster/ubuntu/deployAddons.sh#L29
}
