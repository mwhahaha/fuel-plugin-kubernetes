# Class: kubernetes
# ===========================
#
# This class will install a single host kubernetes via docker.
#
# Parameters
# ----------
#
# N/A
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
#    class { 'kubernetes': }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes {
  include ::kubernetes::docker
  include ::kubernetes::docker::etcd
  include ::kubernetes::docker::hyperkube::kubelet
  include ::kubernetes::docker::hyperkube::proxy
  include ::kubernetes::docker::hyperkube::apiserver
  include ::kubernetes::docker::hyperkube::controller_manager
  include ::kubernetes::docker::hyperkube::scheduler
  include ::kubernetes::kubectl
}
