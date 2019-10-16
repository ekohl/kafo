Facter.add(:environment_modules) do
  setcode do
    modules = {}

    environment = Puppet.lookup(:current_environment)
    environment.modulepath.each do |modulepath|
      Dir[File.join(modulepath, '*', 'metadata.json')].sort.each do |metadata_json|
          metadata = JSON.load(File.read(metadata_json))
          next if modules.key?(metadata['name'])
          next unless metadata['requirements'] && metadata['requirements'].is_a?(Array)

          metadata['requirements'].select { |req| req['name'] == 'puppet' && req['version_requirement'] }.each do |req|
            modules[metadata['name']] = req['version_requirement']
          end
      end
    end

    modules
  end
end

