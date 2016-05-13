require 'spec_helper'
describe 'kubernetes' do

  context 'with default values for all parameters' do
    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::kubectl') }
  end
end
