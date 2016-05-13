require 'spec_helper'
describe 'kubernetes::params' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes::params') }
  end
end
