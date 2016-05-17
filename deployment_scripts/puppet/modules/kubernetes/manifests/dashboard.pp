# Class: kubernetes::dashboard
# ===========================
#
# This class loads the kubernetes dashboard into the system by placing a
# yaml deployment file that can be run with kubectl to add it to the cluster.
#
# Parameters
# ----------
#
# [*container_name*]
#  (Optional) Container to use for the dashboard deployment
#  Defaults to 'gcr.io/google_containers/kubernetes-dashboard-amd64'
#
# [*ui_version*]
#  (Optional) Version of the ui to use
#  Defaults to 'v1.0.1'
#
# [*api_endpoint*]
#  (Optional) api endpoint uri for the UI to use.
#  Defaults to 'http://127.0.0.1:8080'
#
# [*deploy_path*]
#  (Optional) Location to write out the .yaml file to be loaded by kubelet
#  Defaults to '/srv/kubernetes'
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
#    class { 'kubernetes::dashboard':
#      api_endpoint => 'http://10.0.0.1:9999/'
#    }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::dashboard (
  $container_name = 'gcr.io/google_containers/kubernetes-dashboard-amd64',
  $ui_version     = 'v1.0.1',
  $api_endpoint   = 'http://127.0.0.1:8080',
  $deploy_path    = '/srv/kubernetes',
) inherits ::kubernetes::params {

  file { "${deploy_path}/kubernetes-dashboard.yaml":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::kubernetes::params::kubernetes_owner,
    group   => $::kubernetes::params::kubernetes_group,
    content => template("${module_name}/kubernetes-dashboard.yaml.erb")
  }

}
