# Class: kubernetes::docker::kubernetes
# ===========================
#
# This class launches the kubernetes docker containers.
#
# Parameters
# ----------
#
# [*hyperkube_ver*]
#  (Optional) Version of the hyperkube image to use from gcr.io
#  Defaults to 'v1.2.3'
#
# [*master_proto*]
#  (Optional) Protocol to use when talking to the master endpoint
#  Defaults to 'http'
#
# [*master_ip*]
#  (Optional) Ip address of the master endpoint
#  Defaults to '127.0.0.1'
#
# [*master_port*]
#  (Optional) Port for for the master endpoint
#  Defaults to '8080'
#
# [*bind_address*]
#  (Optional) Address to bind to
#  Defaults to '0.0.0.0'
#
# [*cluster_dns*]
# [*cluster_domain*]
#
# [*config_dir*]
#  (Optional) Directory for kuberenetes pods configurations as used by
#  kubelet. This directory needs to exist on both the docker host system
#  and will be mounted rw in the kubelet docker container.
#  Defaults to '/srv/kubernetes-config'
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
class kubernetes::docker::kubernetes (
  $hyperkube_ver  = 'v1.2.3',
  $master_proto   = 'http',
  $master_ip      = '127.0.0.1',
  $master_port    = '8080',
  $bind_address   = '0.0.0.0',
  $cluster_dns    = '10.0.0.10',
  $cluster_domain = 'cluster.local',
  $api_servers    = 'http://127.0.0.1:8080',
  $etcd_servers   = 'http://127.0.0.1:4001',
  $config_dir     = '/srv/kubernetes-config',
) {

  $kube_image = "gcr.io/google_containers/hyperkube-amd64:${hyperkube_ver}"

  file { $config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    tag    => ['kubernetes-config'],
  }

  # master kubernets pods configuration
  file { "${config_dir}/master.json":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/master.json.erb"),
    tag     => ['kubernetes-config'],
  }

  # defaults for the runs
  Docker::Run {
    image      => $kube_image,
    net        => 'host',
    privileged => true,
  }

  $proxy_cmd = join([
    '/hyperkube proxy',
    "--master=${master_proto}://${master_ip}:${master_port}",
    '--v=2',
    '--resource-container=""',
  ], ' ')
  docker::run { 'hyperkube-proxy':
    command    => $proxy_cmd,
  }

  $kubelet_cmd = join([
    '/hyperkube kubelet',
    '--containerized',
    #"--hostname-override=${master_ip}",
    "--address=${bind_address}",
    "--api-servers=${api_servers}",
    "--config=${config_dir}",
    "--cluster-dns=${cluster_dns}",
    "--cluster-domain=${cluster_domain}",
    '--allow-privileged=true',
    '--v=2',
  ], ' ')
  docker::run { 'hyperkube-kubelet':
    command          => $kubelet_cmd,
    volumes          => [
      '/:/rootfs:ro',
      '/sys:/sys:ro',
      '/var/lib/docker/:/var/lib/docker:rw',
      '/var/lib/kubelet/:/var/lib/kubelet:rw',
      '/var/run:/var/run:rw',
      "${config_dir}:${config_dir}:rw" ],
    extra_parameters => [ '--pid=host', ]
  }

  # makes sure kubernetes pods configs are put inplace before starting the
  # kubelet container
  File<| tag == 'kubernetes-config' |> ->
    Docker::Run['hyperkube-kubelet']
}
