define kafka::private::service(
  $type,
  $config_dir      = undef,
  $heap_opts       = undef,
  $jmx_opts        = undef,
  $log4j_opts      = undef,
  $opts            = undef,
  $service_ensure  = running,
  $service_install = true,
  # mirror-specific
  $blacklist       = undef,
  $whitelist       = undef,
  $num_producers   = undef,
  $num_streams     = undef,
) {
  if $caller_module_name != $module_name {
    fail( "Use of private class ${name} by ${caller_module_name}" )
  }

  validate_re( $type, '^(broker|mirror|consumer|producer)$', "Unsupported Kafka config type: ${type}" )

  if ! $service_install {
    debug( 'Skipping service install' )
  } else {
    require ::kafka
    include ::systemd

    # expose some data to unit.erb
    $install_dir = $::kafka::install_dir
    case $type {
      'broker': {
        $broker_opts  = $opts ? { undef => "", default => join( $opts, ' ' ), }
        $service_name = 'kafka'
      }
      'mirror': {
        $mirror_opts  = $opts ? { undef => "", default => prefix( join_keys_to_values( $opts, '=' ), '--' ), }
        $service_name = "kafka-${type}-${name}"
      }
    }

    file { "${service_name}.service":
      ensure  => file,
      path    => "/etc/systemd/system/${service_name}.service",
      mode    => '0644',
      content => template( 'kafka/unit.erb' ),
    } ->

    file { "/etc/init.d/${name}":
      ensure => absent,
    } ->

    service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }

    File["${service_name}.service"] ~>
    Exec['systemd-daemon-reload'] ->
    Service[$service_name]
  }
}
