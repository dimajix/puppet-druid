# == Class: druid::indexing::middle_manager
#
# Setup a Druid node runing the indexing middleManager service.
#
# === Parameters
#
# [*host*]
#   Host address the service listens on.
#
#   Default value: The `$ipaddress` fact.
#
# [*port*]
#   Port the service listens on.
#
#   Default value: `8080`.
#
# [*service*]
#   The name of the service.
#
#   This is used as a dimension when emitting metrics and alerts.  It is
#   used to differentiate between the various services
#
#   Default value: `'druid/middlemanager'`.
#
# [*fork_properties*]
#   Hash of explicit child peon config options.
#
#   Peons inherit the configurations of their parent middle managers, but if
#   this is undesired for certain config options they can be explicitly
#   passed here.
#
#   These key value pairs are expected in Druid config format and are
#   unvalidated.  The keys should NOT include
#   `'druid.indexer.fork.property'` as a prefix.
#
#   Example:
#
#   ```puppet
#     {
#       "druid.monitoring.monitors" => "[\"com.metamx.metrics.JvmMonitor\"]",
#       "druid.processing.numThreads" => 2,
#     }
#   ```
#
#   Default value: `{}`
#
# [*jvm_opts*]
#   Array of options to set for the JVM running the service.
#
#   Default value: [
#     '-server',
#     '-Duser.timezone=UTC',
#     '-Dfile.encoding=UTF-8',
#     '-Djava.io.tmpdir=/tmp',
#     '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
#   ]
#
# [*peon_mode*]
#   Mode peons are run in.
#
#   Valid values:
#     * `'local'`: Standalone mode (Not recommended).
#     * `'remote'`: Pooled.
#
#   Default value: `'remote'`.
#
# [*remote_peon_max_retry_count*]
#   Max retries a remote peon makes communicating with the overlord.
#
#   Default value: `10`.
#
# [*remote_peon_max_wait*]
#   Max retry time a remote peon makes communicating with the overlord.
#
#   Default value: `'PT10M'`.
#
# [*remote_peon_min_wait*]
#   Min retry time a remote peon makes communicating with the overlord.
#
#   Default value: `'PT1M'`.
#
# [*runner_allowed_prefixes*]
#   Array of prefixes of configs that are passed down to peons.
#
#   Default value: `['com.metamx', 'druid', 'io.druid', 'user.timezone', 'file.encoding']`.
#
# [*runner_classpath*]
#   Java classpath for the peons.
#
# [*runner_compress_znodes*]
#   Specify if Znodes are compressed.
#
#   Default value: `true`.
#
# [*runner_java_command*]
#   Command for peons to use to execute java.
#
#   Default value: `'java'`.
#
# [*runner_java_opts*]
#   Java "-X" options for the peon to use in its own JVM.
#
# [*runner_max_znode_bytes*]
#   Maximum Znode size in bytes that can be created in Zookeeper.
#
#   Default value: `524288`.
#
# [*runner_start_port*]
#   Port peons begin running on.
#
#   Default value: `8100`.
#
# [*task_base_dir*]
#   Base temporary working directory.
#
#   Default value: `'/tmp'`.
#
# [*task_base_task_dir*]
#   Base temporary working directory for tasks.
#
#   Default value: `'/tmp/persistent/tasks'`.
#
# [*task_chat_handler_type*]
#   Specify service discovery type.
#
#   Certain tasks will use service discovery to announce an HTTP endpoint
#   that events can be posted to.
#
#   Valid values: `'noop'` or `'announce'`.
#
#   Default value: `'noop'`.
#
# [*task_default_hadoop_coordinates*]
#   Array of default Hadoop versions to use.
#
#   This is used with HadoopIndexTasks that do not request a particular
#   version.
#
#   Default value: `['org.apache.hadoop:hadoop-client:2.3.0']`.
#
# [*task_default_row_flush_boundary*]
#   Highest row count before persisting to disk.
#
#   Used for indexing generating tasks.
#
#   Default value: `50000`.
#
# [*task_hadoop_working_path*]
#   Temporary working directory for Hadoop tasks.
#
#   Default value: `'/tmp/druid-indexing'`.
#
# [*worker_capacity*]
#   Maximum number of tasks to accept.
#
# [*worker_ip*]
#   The IP of the worker.
#
#   Default value: `'localhost'`.
#
# [*worker_version*]
#   Version identifier for the middle manager.
#
#   Default value: `'0'`.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

class druid::indexing::middle_manager (
  $host                            = hiera("${module_name}::indexing::middle_manager::host", $::ipaddress),
  $port                            = hiera("${module_name}::indexing::middle_manager::port", 8080),
  $service                         = hiera("${module_name}::indexing::middle_manager::service", 'druid/middlemanager'),
  $fork_properties                 = hiera_hash("${module_name}::indexing::middle_manager::fork_properties", {}),
  $jvm_opts                        = hiera_array("${module_name}::indexing::middle_manager::jvm_opts", ['-server', '-Duser.timezone=UTC', '-Dfile.encoding=UTF-8', '-Djava.io.tmpdir=/tmp', '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager']),
  $peon_mode                       = hiera("${module_name}::indexing::middle_manager::peon_mode", 'remote'),
  $remote_peon_max_retry_count     = hiera("${module_name}::indexing::middle_manager::remote_peon_max_retry_count", 10),
  $remote_peon_max_wait            = hiera("${module_name}::indexing::middle_manager::remote_peon_max_wait", 'PT10M'),
  $remote_peon_min_wait            = hiera("${module_name}::indexing::middle_manager::remote_peon_min_wait", 'PT1M'),
  $runner_allowed_prefixes         = hiera("${module_name}::indexing::middle_manager::runner_allowed_prefixes", ['com.metamx', 'druid', 'io.druid', 'user.timezone', 'file.encoding']),
  $runner_classpath                = hiera("${module_name}::indexing::middle_manager::runner_classpath", undef),
  $runner_compress_znodes          = hiera("${module_name}::indexing::middle_manager::runner_compress_znodes", true),
  $runner_java_command             = hiera("${module_name}::indexing::middle_manager::runner_java_command", 'java'),
  $runner_java_opts                = hiera("${module_name}::indexing::middle_manager::runner_java_opts", undef),
  $runner_max_znode_bytes          = hiera("${module_name}::indexing::middle_manager::runner_max_znode_bytes", 524288),
  $runner_start_port               = hiera("${module_name}::indexing::middle_manager::runner_start_port", 8100),
  $task_base_dir                   = hiera("${module_name}::indexing::middle_manager::task_base_dir", '/tmp'),
  $task_base_task_dir              = hiera("${module_name}::indexing::middle_manager::task_base_task_dir", '/tmp/persistent/tasks'),
  $task_chat_handler_type          = hiera("${module_name}::indexing::middle_manager::task_chat_handler_type", 'noop'),
  $task_default_hadoop_coordinates = hiera_array("${module_name}::indexing::middle_manager::task_default_hadoop_coordinates", ['org.apache.hadoop:hadoop-client:2.3.0']),
  $task_default_row_flush_boundary = hiera("${module_name}::indexing::middle_manager::task_default_row_flush_boundary", 50000),
  $task_hadoop_working_path        = hiera("${module_name}::indexing::middle_manager::task_hadoop_working_path", '/tmp/druid-indexing'),
  $worker_capacity                 = hiera("${module_name}::indexing::middle_manager::worker_capacity", undef),
  $worker_ip                       = hiera("${module_name}::indexing::middle_manager::worker_ip", 'localhost'),
  $worker_version                  = hiera("${module_name}::indexing::middle_manager::worker_version", '0'),
) {
  require druid::indexing

  validate_re($peon_mode, ['^local$', '^remote$'])
  validate_re($task_chat_handler_type, ['^noop$', '^announce$'])

  validate_string(
    $host,
    $service,
    $remote_peon_max_wait,
    $remote_peon_min_wait,
    $runner_classpath,
    $runner_java_command,
    $runner_java_opts,
    $worker_ip,
    $worker_version,
  )

  validate_integer($port)
  validate_integer($remote_peon_max_retry_count)
  validate_integer($runner_max_znode_bytes)
  validate_integer($runner_start_port)
  validate_integer($task_default_row_flush_boundary)
  if $worker_capacity {
    validate_integer($worker_capacity)
  }

  validate_hash($fork_properties)

  validate_array($runner_allowed_prefixes)
  validate_array($jvm_opts)
  validate_array($task_default_hadoop_coordinates)

  validate_bool($runner_compress_znodes)

  validate_absolute_path($task_base_dir)
  validate_absolute_path($task_base_task_dir)
  validate_absolute_path($task_hadoop_working_path)

  druid::service { 'middle_manager':
    config_content  => template("${module_name}/middle_manager.runtime.properties.erb"),
    service_content => template("${module_name}/druid-middle_manager.service.erb"),
    init_content => template("${module_name}/druid-middle_manager.init.erb"),
  }
}
