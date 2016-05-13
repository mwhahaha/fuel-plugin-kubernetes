require 'spec_helper'
describe 'flannel' do

  context 'with default values for all parameters' do
    it { should contain_class('flannel') }

    it 'should install flannel package' do
     is_expected.to contain_package('flannel')
    end

    it 'should configure upstart' do
      is_expected.to contain_file('/etc/init/flanneld.conf')
    end

    it 'should configure flannel opts' do
      is_expected.to contain_file('/etc/default/flanneld')
    end

    it 'should start flanneld service' do
      is_expected.to contain_service('flanneld')
    end
  end
end
