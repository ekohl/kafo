require 'spec_helper'

describe 'kafo_configure::version_checks' do
  context 'valid modules' do
    let(:facts) do
      {
        puppetversion: '1.2.3',
        environment_modules: {
          all_accepting: '>= 0',
          valid_bounds: '>= 1.0.0 < 2.0.0',
        }
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_kafo_configure__puppet_version_semver('all_accepting').with_requirement('>= 0') }
    it { is_expected.to contain_kafo_configure__puppet_version_semver('valid_bounds').with_requirement('>= 1.0.0 < 2.0.0') }
  end

  context 'invalid modules' do
    let(:facts) do
      {
        puppetversion: '1.2.3',
        environment_modules: {
          newer_required: '>= 2',
        }
      }
    end

    it { is_expected.to raise_error(/kafo_configure::puppet_version_failure: Puppet 1\.2\.3 does not meet requirements for newer_required \(>= 2\)/) }
  end
end
