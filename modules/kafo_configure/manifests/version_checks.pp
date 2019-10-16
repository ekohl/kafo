# A class to check all present modules if they support the Puppet version
class kafo_configure::version_checks {
  $facts['environment_modules'].each |$module, $requirement| {
    kafo_configure::puppet_version_semver { $module:
      requirement => $requirement,
    }
  }
}
