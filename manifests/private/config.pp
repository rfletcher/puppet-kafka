define kafka::private::config(
  $config       = {},
  $config_dir   = undef,
  $id           = undef,
  $service_name = undef,
  $source_name  = $name,
  $type,
) {
  if $caller_module_name != $module_name {
    fail( "Use of private class ${name} by ${caller_module_name}" )
  }

  validate_re( $type, '^(broker|consumer|producer)$', "Unsupported Kafka config type: ${type}" )

  include ::kafka

  # validate version- and type-specific config requirements
  if $::kafka::version {
    case $type {
      'broker': {
        if versioncmp( $::kafka::version, '0.9.0.0' ) < 0 {
          if $config['broker.id'] == '-1' {
            fail( '[Broker] You need to specify a value for broker.id' )
          }
        }
      }
      'consumer': {
        if $config['group.id'] == '' {
          fail( '[Consumer] You need to specify a value for group.id' )
        }
        if versioncmp( $::kafka::version, '0.10.0.0' ) < 0 {
          if $config['zookeeper.connect'] == '' {
            fail( '[Consumer] You need to specify a value for zookeeper.connect' )
          }
        }
      }
      'producer': {
        if versioncmp( $::kafka::version, '0.9.0.0' ) < 0 {
          if $config['metadata.broker.list'] == '' {
            fail( '[Producer] You need to specify a value for metadata.broker.list' )
          }
        } else {
          if $config['bootstrap.servers'] == '' {
            fail( '[Producer] You need to specify a value for bootstrap.servers' )
          }
        }
      }
    }
  }

  $config_name = $type ? {
    'broker' => 'server',
    default  => $type,
  }

  if $type == 'broker' or $config['client.id'] {
    $real_config = $config
  } else {
    $real_config = merge( $config, {
      'client.id' => join( ['mirror', $source_name, $type, $id], '-' ),
    } )
  }

  if $config_dir {
    $real_config_dir = "${::kafka::config_dir}/${config_dir}"

    exec { "kafka-config-${name} mkdir":
      command => "mkdir -p ${real_config_dir}",
      creates => $real_config_dir,
      before  => File["${real_config_dir}/${config_name}.properties"],
    }
  } else {
    $real_config_dir = "${::kafka::config_dir}"
  }

  file { "${real_config_dir}/${config_name}.properties":
    ensure  => present,
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    content => template( 'kafka/properties.erb' ),
    notify  => $service_name ? {
      undef   => undef,
      default => Service[$service_name],
    },
    require => File[$::kafka::config_dir],
  }
}
