require 'spec_helper'
describe 'kubernetes::kubelet' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes::kubelet') }

    it 'should install kubelet package' do
     is_expected.to contain_package('kubelet')
    end

    it 'should configure upstart' do
      is_expected.to contain_file('/etc/init/kubelet.conf')
    end

    it 'should configure opts' do
      is_expected.to contain_file('/etc/default/kubelet')
    end

    it 'should start kubelet service' do
      is_expected.to contain_service('kubelet')
    end

    it 'should create config dir' do
      is_expected.to contain_file('/srv/kubernetes-config')
    end
  end
end
