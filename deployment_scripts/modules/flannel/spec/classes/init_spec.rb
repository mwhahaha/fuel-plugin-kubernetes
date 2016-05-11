require 'spec_helper'
describe 'flannel' do

  context 'with default values for all parameters' do
    it { should contain_class('flannel') }
  end
end
