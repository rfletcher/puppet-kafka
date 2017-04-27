class kafka::broker (
  $config     = {},
  $heap_opts  = $::kafka::params::broker_heap_opts,
  $jmx_opts   = $::kafka::params::broker_jmx_opts,
  $log4j_opts = $::kafka::params::broker_log4j_opts,
  $opts       = $::kafka::params::broker_opts,
) inherits kafka::params {
  include ::kafka

  ::kafka::private::config { $name:
    config       => $config,
    service_name => 'kafka',
    type         => 'broker',
  }

  ::kafka::private::service { $name:
    heap_opts  => $heap_opts,
    jmx_opts   => $jmx_opts,
    log4j_opts => $log4j_opts,
    opts       => $opts,
    type       => 'broker',
  }
}
