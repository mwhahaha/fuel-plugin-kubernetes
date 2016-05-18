# Class: plugin_k8s::keepalived
# ===========================
#
# This class installs and configures our vip with keepalived
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
#    include ::plugin_k8s::keepalived
#
class plugin_k8s::keepalived {
  notice('MODULAR: plugin_k8s/keepalived.pp')

  include ::plugin_k8s::params

  class { '::keepalived':
    service_restart => 'service keepalived restart',
    service_manage  => true,
  }

  # NOTE: We use the management interface for the keepalived traffic, but use
  # the vip interface for the vip.  If we want to use the same interface, we
  # could but we'll need to switch out management ips for the peers
  keepalived::vrrp::instance { $::plugin_k8s::params::vip_name:
    interface           => $::plugin_k8s::params::management_interface,
    state               => 'BACKUP',
    nopreempt           => true,
    virtual_router_id   => '50',
    priority            => '100',
    garp_master_delay   => 3,
    garp_master_refresh => 60,
    auth_type           => 'PASS',
    auth_pass           => 'asecretpassword', # TODO: fixme
    virtual_ipaddress   => $::plugin_k8s::params::api_vip,
    unicast_source_ip   => $::plugin_k8s::params::mgmt_ip,
    unicast_peers       => $::plugin_k8s::params::controller_mgmt_ips,
  }

  # (╯°□°）╯︵ ┻━┻
  tweaks::ubuntu_service_override { 'keepalived': }

  Keepalived::Vrrp::Instance[$::plugin_k8s::params::vip_name] ~>
    Service[$::keepalived::service_name]
}
