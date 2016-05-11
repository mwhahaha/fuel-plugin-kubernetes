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
  file { '/usr/local/bin/kubectl':
    ensure => $ensure,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/kubectl",
  }
}
