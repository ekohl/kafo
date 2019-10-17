module Kafo
  class PuppetConfigurer
    def self.write_config(config_path, settings)
      File.open(config_path, 'w') do |file|
        file.puts '[main]'
        settings.keys.sort.each do |key|
          file.puts "#{key} = #{settings[key]}"
        end
      end
    end
  end
end
