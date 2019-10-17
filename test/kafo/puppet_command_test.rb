require 'test_helper'

module Kafo
  describe PuppetCommand do
    let(:configuration) { Configuration.new(ConfigFileFactory.build('basic', BASIC_CONFIGURATION).path) }
    let(:options) { [] }
    let(:puppetconf) { nil }
    let(:pc) { PuppetCommand.new('', options, puppetconf, configuration) }

    describe "#command" do
      describe "with defaults" do
        specify { assert_kind_of(String, pc.command) }
        specify { assert_includes(pc.command, 'puppet apply --modulepath /') }
        specify { assert_includes(pc.command, 'kafo_configure::puppet_version_semver { "theforeman-kafo_configure":') }

        specify { KafoConfigure.stub(:verbose, false) { assert_includes(pc.command, '$kafo_add_progress=true') } }
        specify { KafoConfigure.stub(:verbose, true) { assert_includes(pc.command, '$kafo_add_progress=false') } }

        specify { PuppetCommand.stub(:search_puppet_path, '/opt/puppetlabs/bin/puppet') { assert_includes(pc.command, '/opt/puppetlabs/bin/puppet apply') } }
      end

      describe "with PuppetConfigurer" do
        let(:puppetconf) { MiniTest::Mock.new }

        specify do
          puppetconf.expect(:config_path, '/tmp/puppet.conf') do
            puppetconf.expect(:write_config, nil) do
              assert_includes(pc.command, ' --config=/tmp/puppet.conf ')
            end
          end
        end
      end

      describe "with version checks" do
        specify do
          pc.stub(:modules_path, ['/modules']) do
            Dir.stub(:[], ['./test/fixtures/metadata/basic.json']) do
              assert_includes(pc.command, 'kafo_configure::puppet_version_semver { "theforeman-testing":')
              assert_includes(pc.command, 'requirement => ">= 3.0.0 < 999.0.0"')
            end
          end
        end

        specify do
          configuration.app[:skip_puppet_version_check] = true
          pc.stub(:modules_path, ['/modules']) do
            Dir.stub(:[], ['./test/fixtures/metadata/basic.json']) do
              refute_includes(pc.command, 'kafo_configure::puppet_version')
            end
          end
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
