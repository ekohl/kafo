require 'test_helper'
require 'tempfile'
require 'kafo/hiera_configurer'

module Kafo
  describe PuppetConfigurer do
    let(:config) { Tempfile.new('config') }

    describe "write_config" do
      let(:settings) { {'noop' => false, 'reports' => ''} }
      before { PuppetConfigurer.write_config(config.path, settings) }
      specify { assert File.exist?(config.path) }
      specify { assert_equal("[main]\nnoop = false\nreports = \n", File.read(config.path)) }
    end
  end
end
