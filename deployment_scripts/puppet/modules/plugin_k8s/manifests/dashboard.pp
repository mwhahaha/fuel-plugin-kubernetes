# Class: plugin_k8s::dashboard
# ===========================
#
# This class is our task to deploy the kubernetes dashboard via kubelet
#
# Parameters
# ----------
#
#
# Variables
# ----------
#
#
# Examples
# --------
#
# @example
#    include ::plugin_k8s::dashboard
#
class plugin_k8s::dashboard {
  notice('MODULAR: plugin_k8s/dashboard.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::dashboard':
    api_endpoint => $::plugin_k8s::params::api_vip_url,
  }
  # only load the dashbard on the primary controller
  if $::plugin_k8s::params::primary_controller {
    exec { 'load-dashboard':
      path        => [ '/bin', '/usr/bin', '/usr/local/bin'],
      environment => ['HOME=/root'],
      command     => 'kubectl create -f /srv/kubernetes/kubernetes-dashboard.yaml',
      unless      => 'kubectl cluster-info | grep -q kubernetes-dashboard',
      require     => Class['::kubernetes::dashboard'],
    }
  }

}
