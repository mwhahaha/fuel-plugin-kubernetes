# Class: plugin_k8s::kubectl
# ===========================
#
# This class installs the kubectl client and configures the default cluster
# configuration for it
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
#    include ::plugin_k8s::kubectl
#
class plugin_k8s::kubectl {
  notice('MODULAR: plugin_k8s/kubectl.pp')

  include ::plugin_k8s::params

  class { '::kubernetes::kubectl': }->
  # TODO: make idempotent
  exec { 'set-cluster':
    path        => [ '/bin', '/usr/bin', '/usr/local/bin'],
    environment => ['HOME=/root'],
    command     => "kubectl config set-cluster fuel --server=${::plugin_k8s::params::api_vip_url} --insecure-skip-tls-verify=true",
  }->
  exec { 'set-context':
    path        => [ '/bin', '/usr/bin', '/usr/local/bin'],
    environment => ['HOME=/root'],
    command     => 'kubectl config set-context fuel --cluster=fuel'
  }->
  exec { 'use-context':
    path        => [ '/bin', '/usr/bin', '/usr/local/bin'],
    environment => ['HOME=/root'],
    command     => 'kubectl config use-context fuel'
  }
}
