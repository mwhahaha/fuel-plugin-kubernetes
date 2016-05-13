# Class: kubernetes::apiserver
# ===========================
#
# This class launches the kubernetes apiserver.
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
#    class { 'kubernetes::apiserver':
#    }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::apiserver (
  $bind_address           = '0.0.0.0',
  $secure_port            = '6443',
  $insecure_bind_address  = '0.0.0.0',
  $insecure_port          = '8080',
  $apiserver_count        = 1,
  $etcd_servers           = 'http://127.0.0.1:4001',
  $service_cluster_ips    = '10.0.0.1/24',
  $apiserver_dir          = '/srv/kubernetes',
) {

  include ::kubernetes::params


  $apiserver_opts = join([
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

  ensure_resource('file', [$apiserver_dir], {
    ensure => 'directory',
    tag    => 'apiserver',
  })
  ensure_resource('file', ["${apiserver_dir}/basic_auth.csv"], {
    ensure  => 'file',
    content => 'admin,admin,admin',
    tag     => 'apiserver',
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
    tag     => 'apiserver',
  })

  #TODO(adidenko): better packages
  package { 'kube-apiserver':
    ensure => installed,
    tag    => ['apiserver',]
  }

  file { '/etc/init/kube-apiserver.conf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/kube-apiserver.conf",
    tag    => [ 'apiserver', ],
  }

  file { '/etc/default/kube-apiserver':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/kube-apiserver.erb"),
    tag     => [ 'apiserver', ],
  }

  service { 'kube-apiserver':
    ensure   => 'running',
    enable   => true,
    provider => 'upstart'
  }

  # ensure files are created prior to running the api server
  Package<| tag == 'apiserver' |> ->
  File<| tag == 'apiserver' |> ~>
  Service['kube-apiserver']

  # TODO(aschultz): for HA we need to create a kube-system namespace
  # see https://github.com/kubernetes/kubernetes/blob/master/cluster/ubuntu/deployAddons.sh#L29
}
