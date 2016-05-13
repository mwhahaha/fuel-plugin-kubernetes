require 'spec_helper'
describe 'etcd' do

  context 'with default values for all parameters' do
    it { is_expected.to contain_class('etcd') }

    it 'should contain etcd package' do
      is_expected.to contain_package('etcd')
    end

    it 'should create etcd upstart config' do
      is_expected.to contain_file('/etc/init/etcd.conf')
    end

    it 'should create etcd cmd line options' do
      is_expected.to contain_file('/etc/default/etcd')
    end

    it 'should create etcd data dir' do
      ['/var/etcd', '/var/etcd/data'].each do |d|
        is_expected.to contain_file(d)
      end
    end
    it 'should start etcd' do
      is_expected.to contain_service('etcd')
    end
  end
end
