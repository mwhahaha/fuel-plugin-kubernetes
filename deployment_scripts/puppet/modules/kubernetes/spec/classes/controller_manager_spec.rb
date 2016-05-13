require 'spec_helper'
describe 'kubernetes::controller_manager' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes::controller_manager') }

    it 'should install kube-controller-manager package' do
     is_expected.to contain_package('kube-controller-manager')
    end

    it 'should configure upstart' do
      is_expected.to contain_file('/etc/init/kube-controller-manager.conf')
    end

    it 'should configure opts' do
      is_expected.to contain_file('/etc/default/kube-controller-manager')
    end

    it 'should start kube-controller-manager service' do
      is_expected.to contain_service('kube-controller-manager')
    end
  end
end
