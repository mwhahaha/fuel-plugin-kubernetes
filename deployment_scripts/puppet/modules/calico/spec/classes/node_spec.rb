require 'spec_helper'
describe 'calico::node' do

  context 'with default values for all parameters' do
    it {
      should contain_exec('setup-calico-node').with(
        'tag'         => ['calico'],
        'environment' => 'ETCD_ENDPOINTS=http://127.0.0.1:2379',
        'command'     => 'calicoctl node'
      )
    }
  end
end
