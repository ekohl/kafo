# encoding: UTF-8
module Kafo
  class PuppetCommand
    def initialize(command, options = [], puppet_config = nil, configuration = KafoConfigure.config)
      @configuration = configuration
      @command = command
      @puppet_config = puppet_config

      if puppet_config
        puppet_config['basemodulepath'] = modules_path.join(':')
        @options = options.push("--config=#{puppet_config.config_path}")
      else
        @options = options.push("--modulepath #{modules_path.join(':')}")
      end
      @logger  = KafoConfigure.logger
      @puppet_version_check = !configuration.app[:skip_puppet_version_check]
      @suffix = nil
    end

    def command
      @puppet_config.write_config if @puppet_config
      result = [
          manifest,
          '|',
          "RUBYLIB=#{[@configuration.kafo_modules_dir, ::ENV['RUBYLIB']].join(File::PATH_SEPARATOR)}",
          "#{puppet_path} apply #{@options.join(' ')} #{@suffix}",
      ].join(' ')
      @logger.debug result
      result
    end

    def append(suffix)
      @suffix = suffix
      self
    end

    def self.search_puppet_path(bin_name)
      bin_path = (::ENV['PATH'].split(File::PATH_SEPARATOR) + ['/opt/puppetlabs/bin']).find do |path|
        File.executable?(File.join(path, bin_name))
      end
      File.join([bin_path, bin_name].compact)
    end

    private

    def manifest
      %{echo '
        #{add_progress}
        #{generate_version_checks if @puppet_version_check}
        #{@command}
      '}
    end

    def add_progress
      %{$kafo_add_progress=#{!KafoConfigure.verbose}}
    end

    def generate_version_checks
      'include kafo_configure::version_checks'
    end

    def modules_path
      [
          @configuration.module_dirs,
          @configuration.kafo_modules_dir,
      ].flatten
    end

    def puppet_path
      @puppet_path ||= self.class.search_puppet_path('puppet')
    end
  end
end
