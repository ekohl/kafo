# encoding: UTF-8
module Kafo
  class PuppetCommand
    def self.build_command(command, configuration, options = [], suffix = nil)
      [
          %{echo '
            $kafo_add_progress=#{!KafoConfigure.verbose}
            #{'include kafo_configure::version_checks' unless configuration.app[:skip_puppet_version_check]}
            #{command}
          '},
          '|',
          "RUBYLIB=#{[configuration.kafo_modules_dir, ::ENV['RUBYLIB']].join(File::PATH_SEPARATOR)}",
          "#{search_puppet_path('puppet')} apply #{options.join(' ')} #{suffix}",
      ].join(' ')
    end

    def self.search_puppet_path(bin_name)
      bin_path = (::ENV['PATH'].split(File::PATH_SEPARATOR) + ['/opt/puppetlabs/bin']).find do |path|
        File.executable?(File.join(path, bin_name))
      end
      File.join([bin_path, bin_name].compact)
    end
  end
end
