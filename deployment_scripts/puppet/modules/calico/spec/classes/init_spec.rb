require 'spec_helper'
describe 'calico' do

  context 'with default values for all parameters' do
    it { should contain_class('calico') }
  end
end
