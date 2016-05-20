require 'spec_helper'
describe 'calico::cni' do

  context 'with default values for all parameters' do
    it {
      should contain_package('calico').with(
        'ensure' => 'installed',
        'tag'    => ['calico']
      )
    }
    it {
      should contain_file('/etc/cni/net.d/10-calico.conf').with(
        'ensure' => 'file',
        'tag'    => ['calico']
      )
    }
  end
end
