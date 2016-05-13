require 'spec_helper'
describe 'kubernetes::proxy' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes::proxy') }

    it 'should install kube-proxy package' do
     is_expected.to contain_package('kube-proxy')
    end

    it 'should configure upstart' do
      is_expected.to contain_file('/etc/init/kube-proxy.conf')
    end

    it 'should configure opts' do
      is_expected.to contain_file('/etc/default/kube-proxy')
    end

    it 'should start kube-proxy service' do
      is_expected.to contain_service('kube-proxy')
    end
  end
end
