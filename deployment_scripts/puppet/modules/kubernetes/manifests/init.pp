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
  include ::kubernetes::kubectl
}
