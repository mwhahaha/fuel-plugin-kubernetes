# Class: plugin_k8s::params
# ===========================
#
# This class centralized our configuration items used by the fuel kubernetes
# plugin.
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
#    include ::plugin_k8s::params
#
class plugin_k8s::params {

  # plugin hiera settings
  $settings = hiera('fuel-plugin-kubernetes', {})

  # fuel specific network setup items
  $network_scheme = hiera_hash('network_scheme', {})
  prepare_network_config($network_scheme)
  $network_metadata = hiera_hash('network_metadata', {})

  # networking params
  # fuel network-group --create --node-group 2 --name kubernetes --release 1 --vlan 1000 --cidr 10.244.0.0/16
  $cluster_interface = pick(get_network_role_property('kubernetes', 'interface'), 'br-kubernetes')
  $cluster_network = pick($settings['internal_net'], '10.246.0.0/16')
  $service_network = pick(get_network_role_property('kubernetes', 'network'), '10.244.0.0/16')

  # node params
  $node = hiera('node')
  $node_name = $node['name']
  $mgmt_ip = get_network_role_property('management', 'ipaddr')
  $bind_address = $mgmt_ip
  $primary_controller = roles_include('primary-kubernetes-controller')

  # controllers
  $controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-kubernetes-controller', 'kubernetes-controller'])
  $controller_mgmt_nodes = get_node_to_ipaddr_map_by_network_role($controller_nodes, 'management')
  $controller_mgmt_ips = ipsort(values($controller_mgmt_nodes))


  # etcd settings
  $etcd_port = '4001'
  $etcd_peer_port = '2380'
  $etcd_servers = suffix(prefix($controller_mgmt_ips, 'http://'), ":${etcd_port}")
  $etcd_servers_list = join($etcd_servers, ',')
  $etcd_servers_named_list = join(suffix(join_keys_to_values($controller_mgmt_nodes,"=http://"), ":${etcd_peer_port}"), ',')
  $etcd_bootstrap_cluster = true
  $etcd_bootstrap_token = 'fuel-cluster-token'
  $etcd_bootstrap_cluster_state = 'new'

  # api service settigns
  $api_secure_port = '6443'
  $api_insecure_port = '8080'
  $api_server_count = size($controller_nodes)
  $api_nodes = suffix($controller_mgmt_ips, ":${api_insecure_port}")
  $api_proto = 'http'

  # vip settings
  $vip_name = 'kube-apiserver'
  $vip_interface = get_network_role_property('kubernetes', 'interface')
  $api_vip = $network_metadata['vips'][$vip_name]['ipaddr']
  $api_vip_port = '8080' # TODO: ssl?
  $api_vip_proto = 'http'
  $api_vip_url = "${api_vip_proto}://${api_vip}:${api_vip_port}"

  # HA settings
  if $api_server_count > 1 {
    $leader_elect = true
  } else {
    $leader_elect = false
  }

  # flannel settings
  $flannel_port = 8285
  $flannel_type = 'udp'
  $flannel_proto = 'udp'

  # kubelet settings
  $dns_server = hiera('management_vrouter_vip')
  $dns_domain = 'test.domain.local' # TODO fix me

}
