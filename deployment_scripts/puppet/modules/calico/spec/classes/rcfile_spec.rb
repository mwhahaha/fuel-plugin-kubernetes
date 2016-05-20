require 'spec_helper'
describe 'calico::rcfile' do

  context 'with default values for all parameters' do
    it {
      should contain_file('/root/calicorc').with(
        'tag'     => ['calico'],
        'ensure'  => 'file',
      )
    }
    it {
      should contain_file('/root/calicorc').with_content(
        /ETCD_ENDPOINTS='http:\/\/127.0.0.1:2379'/
      )
    }
  end
end
