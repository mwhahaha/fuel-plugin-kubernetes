require 'spec_helper'
describe 'kubernetes::apiserver' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes::apiserver') }

    it 'should install kube-apiserver package' do
     is_expected.to contain_package('kube-apiserver')
    end

    it 'should configure upstart' do
      is_expected.to contain_file('/etc/init/kube-apiserver.conf')
    end

    it 'should configure kubernetes opts' do
      is_expected.to contain_file('/etc/default/kube-apiserver')
    end

    it 'should start kube-apiserver service' do
      is_expected.to contain_service('kube-apiserver')
    end

    it 'should configure token data' do
      ['/srv/kubernetes', '/srv/kubernetes/basic_auth.csv', '/srv/kubernetes/known_tokens.csv'].each do |d|
        is_expected.to contain_file(d)
      end
    end

  end
end
