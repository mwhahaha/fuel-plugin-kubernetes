require 'spec_helper'
describe 'plugin_k8s' do

  context 'with default values for all parameters' do
    it { should contain_class('plugin_k8s') }
  end
end
