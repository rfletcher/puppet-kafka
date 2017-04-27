define kafka::mirror (
  $id,
  $consumer_config = {},
  $producer_config = {},
  $heap_opts       = undef,
  $jmx_opts        = undef,
  $log4j_opts      = [],
  $opts            = undef,
  $num_producers   = undef,
  $num_streams     = undef,
  $blacklist       = undef,
  $whitelist       = undef,
) {
  include ::kafka
  include ::kafka::params

  $config_dir = "mirror-${name}"

  Kafka::Private::Config {
    config_dir   => $config_dir,
    id           => $id,
    service_name => "kafka-mirror-${name}",
    source_name  => $name,
  }

  ::kafka::private::config { "${name}-consumer":
    config => merge( { 'group.id' => "mirror-${name}", }, $consumer_config ),
    type   => 'consumer',
  }

  ::kafka::private::config { "${name}-producer":
    config => $producer_config,
    type   => 'producer',
  }

  ::kafka::private::service { $name:
    type          => 'mirror',
    config_dir    => $config_dir,
    heap_opts     => pickx( $heap_opts,     $::kafka::params::mirror_heap_opts ),
    jmx_opts      => pickx( $jmx_opts,      $::kafka::params::mirror_jmx_opts ),
    log4j_opts    => concat( $::kafka::params::mirror_log4j_opts, ["-Dkafka.logs.dir=${::kafka::service_log_dir}/mirror-${name}"], $log4j_opts ),
    opts          => pickx( $opts,          $::kafka::params::mirror_opts ),
    num_producers => pickx( $num_producers, $::kafka::params::num_producers ),
    num_streams   => pickx( $num_streams,   $::kafka::params::num_streams ),
    blacklist     => pickx( $blacklist,     $::kafka::params::blacklist ),
    whitelist     => pickx( $whitelist,     $::kafka::params::whitelist ),
  }
}
