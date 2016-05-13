require 'spec_helper'
describe 'kubernetes::scheduler' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes::scheduler') }

    it 'should install kube-scheduler package' do
     is_expected.to contain_package('kube-scheduler')
    end

    it 'should configure upstart' do
      is_expected.to contain_file('/etc/init/kube-scheduler.conf')
    end

    it 'should configure opts' do
      is_expected.to contain_file('/etc/default/kube-scheduler')
    end

    it 'should start kube-scheduler service' do
      is_expected.to contain_service('kube-scheduler')
    end
  end
end
