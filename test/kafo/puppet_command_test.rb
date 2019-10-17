require 'test_helper'

module Kafo
  describe PuppetCommand do
    describe ".build_command" do
      let(:command) { '' }
      let(:options) { [] }
      let(:configuration) { Configuration.new(ConfigFileFactory.build('basic', BASIC_CONFIGURATION).path) }
      subject { PuppetCommand.build_command(command, configuration, options) }

      specify { assert_kind_of(String, subject) }
      specify { assert_includes(subject, 'kafo_configure::version_checks') }
      specify { assert_includes(subject, 'puppet apply') }

      specify { KafoConfigure.stub(:verbose, false) { assert_includes(subject, '$kafo_add_progress=true') } }
      specify { KafoConfigure.stub(:verbose, true) { assert_includes(subject, '$kafo_add_progress=false') } }

      specify do
        PuppetCommand.stub(:search_puppet_path, '/opt/puppetlabs/bin/puppet') do
          assert_includes(subject, '/opt/puppetlabs/bin/puppet apply')
        end
      end

      describe 'with options' do
        let(:options) { ['--config=/tmp/kafo/puppet.conf'] }
        specify do
          assert_includes(subject, 'puppet apply --config=/tmp/kafo/puppet.conf')
        end
      end

      describe "without version checks" do
        specify do
          configuration.app[:skip_puppet_version_check] = true
          refute_includes(subject, 'kafo_configure::puppet_version')
        end
      end
    end

    describe '.search_puppet_path' do
      let(:pc) { PuppetCommand.search_puppet_path('puppet') }

      describe "with 'puppet' in PATH" do
        specify do
          ::ENV.stub(:[], '/usr/bin:/usr/local/bin') do
            File.stub(:executable?, Proc.new { |path| path == '/usr/local/bin/puppet' }) do
              assert_equal('/usr/local/bin/puppet', pc)
            end
          end
        end
      end

      describe "with AIO 'puppet' only" do
        specify do
          ::ENV.stub(:[], '/usr/bin:/usr/local/bin') do
            File.stub(:executable?, Proc.new { |path| path == '/opt/puppetlabs/bin/puppet' }) do
              assert_equal('/opt/puppetlabs/bin/puppet', pc)
            end
          end
        end
      end

      describe "with no 'puppet' found in PATH" do
        specify { File.stub(:executable?, false) { assert_equal('puppet', pc) } }
      end
    end
  end
end
