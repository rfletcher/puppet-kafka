class kafka (
  $config_dir      = $::kafka::params::config_dir,
  $group           = $::kafka::params::group,
  $group_id        = $::kafka::params::group_id,
  $install_dir     = $::kafka::params::install_dir,
  $log_dir         = $::kafka::params::log_dir,
  $mirror_digest   = $::kafka::params::mirror_digest,
  $mirror_url      = $::kafka::params::mirror_url,
  $scala_version   = $::kafka::params::scala_version,
  $service_log_dir = $::kafka::params::service_log_dir,
  $user            = $::kafka::params::user,
  $user_id         = $::kafka::params::user_id,
  $version         = $::kafka::params::version,
) inherits kafka::params {
  validate_re($::osfamily, 'RedHat|Debian\b', "${::operatingsystem} not supported")
  validate_absolute_path($config_dir)
  validate_absolute_path($install_dir)
  validate_absolute_path($log_dir)
  validate_absolute_path($service_log_dir)

  $basename     = "kafka_${scala_version}-${version}"
  $basefilename = "${basename}.tgz"
  $package_url  = "${mirror_url}/kafka/${version}/${basefilename}"

  $source = $mirror_url ? {
    /tgz$/  => $mirror_url,
    default => $package_url,
  }

  group { $group:
    ensure => present,
    gid    => $group_id,
  }

  user { $user:
    ensure  => present,
    shell   => '/bin/bash',
    require => Group[$group],
    uid     => $user_id,
  }

  File {
    owner   => $user,
    group   => $group,
    require => [
      Group[$group],
      User[$user],
    ],    
  }

  file { [
    $log_dir,
    $service_log_dir,
  ]:
    ensure => directory,
  }

  file { [
    $config_dir,
    $install_dir,
  ]:
    ensure  => directory,
    recurse => true,
  }

  archive { $basename:
    checksum      => $mirror_digest ? { undef => false, default => true, },
    digest_string => $mirror_digest,
    extension     => regsubst( $source, '^.*\.(tar\.gz|[^.]+)$', '\1' ),
    root_dir      => '.',
    target        => $install_dir,
    url           => $source,
    before        => [
      File[$config_dir],
      File[$install_dir],
    ],
    require => [
      Group['kafka'],
      User['kafka'],
    ],
  }

  exec { 'kafka-remove-parent-dir':
    command => "mv ${basename}/* .; rm -rf ${basename}",
    creates => "${install_dir}/site-docs",
    cwd     => $install_dir,
    before  => File[$install_dir],
    require => Archive[$basename],
  }

  exec { 'kafka-move-default-configs':
    command     => "mv config ${config_dir}",
    cwd         => $install_dir,
    unless      => "test -d ${config_dir}",
    before      => [
      File[$config_dir],
      File["${install_dir}/config"],
    ],
    require     => Exec['kafka-remove-parent-dir'],
  }

  file { "${install_dir}/config":
    ensure  => link,
    target  => $config_dir,
    require => Exec['kafka-move-default-configs'],
  }

  file { "${install_dir}/logs":
    ensure  => link,
    target  => $service_log_dir,
    require => Exec['kafka-remove-parent-dir'],
  }
}
