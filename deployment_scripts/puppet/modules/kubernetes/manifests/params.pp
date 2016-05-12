class kubernetes::params {
  $version = 'v1.2.4'
  $version_file_source = "puppet:///modules/${module_name}/${::kubernetes::params::version}"
}
