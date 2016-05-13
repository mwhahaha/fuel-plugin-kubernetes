# Class: kubernetes::kubectl
# ===========================
#
# This class install the kubectl cli tool.
#
# Parameters
# ----------
#
# [*ensure*]
#  (Optional) Ensure set to `present` will install the kubectl binary to
#  /usr/local/bin. To remove the binary, set this to `absent`.
#  Defaults to 'present'
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
#    class { 'kubernetes::kubectl':  }
#
# Authors
# -------
#
# Alex Schultz <aschultz@mirantis.com>
#
class kubernetes::kubectl (
  $ensure = present
) {
  include ::kubernetes::params
  package { 'kubectl':
    ensure => $ensure,
  }
}
