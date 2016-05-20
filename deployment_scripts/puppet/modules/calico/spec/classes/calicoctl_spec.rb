require 'spec_helper'
describe 'calico::calicoctl' do

  context 'with default values for all parameters' do
    it {
      should contain_package('calicoctl').with(
        'ensure' => 'installed',
        'tag'    => ['calico']
      )
    }
  end
end
