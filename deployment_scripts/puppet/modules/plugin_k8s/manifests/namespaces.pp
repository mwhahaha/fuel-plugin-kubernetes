# Class: plugin_k8s::namespaces
# ===========================
#
# This class sets up the HA namespaces in kubernetes
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
#    include ::plugin_k8s::namespaces
#
class plugin_k8s::namespaces {
  notice('MODULAR: plugin_k8s/namespaces.pp')

  # the kube-system namespace is needed for HA functions
  exec { 'create-kube-system-namespace':
    path        => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    environment => [ 'HOME=/root' ],
    command     => 'kubectl create namespace kube-system',
    unless      => 'kubectl get namespace | grep -q kube-system',
    tries       => 10,
    try_sleep   => 10,
  }
}
