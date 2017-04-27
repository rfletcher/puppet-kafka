class kafka::params {
  $config_dir      = '/etc/kafka'
  $group           = 'kafka'
  $group_id        = undef
  $install_dir     = "/opt/kafka-${scala_version}-${version}"
  $log_dir         = '/var/log/kafka-logs'
  $mirror_url      = 'http://mirrors.ukfast.co.uk/sites/ftp.apache.org'
  $mirror_digest   = '45c7d032324e16c2e19a7d904a4d65c6'
  $scala_version   = '2.11'
  $service_log_dir = '/var/log/kafka'
  $user            = 'kafka'
  $user_id         = undef
  $version         = '0.10.1.0'

  $broker_jmx_opts = [
    '-Dcom.sun.management.jmxremote',
    '-Dcom.sun.management.jmxremote.authenticate=false',
    '-Dcom.sun.management.jmxremote.ssl=false',
    '-Dcom.sun.management.jmxremote.port=9990',
  ]
  $broker_heap_opts  = ['-Xmx1G', '-Xms1G']
  $broker_log4j_opts = ["-Dkafka.logs.dir=${service_log_dir}", "-Dlog4j.configuration=file:config/log4j.properties"]
  $broker_opts       = []

  $mirror_heap_opts  = ['-Xmx256M']
  $mirror_jmx_opts   = []
  $mirror_log4j_opts = $broker_log4j_opts
  $mirror_opts       = {
    'abort.on.send.failure' => true,
  }

  #https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=27846330
  #https://kafka.apache.org/documentation.html#basic_ops_mirror_maker
  $num_streams           = 2
  $num_producers         = 1
  $abort_on_send_failure = true
  $mirror_max_heap       = '256M'
  $whitelist             = '.*'
  $blacklist             = ''
}
