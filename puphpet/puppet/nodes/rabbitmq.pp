if $rabbitmq_values == undef { $rabbitmq_values = hiera('rabbitmq', false) }
if $php_values == undef { $php_values = hiera('php', false) }
if $apache_values == undef { $apache_values = hiera('apache', false) }
if $nginx_values == undef { $nginx_values = hiera('nginx', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1)
  or hash_key_equals($nginx_values, 'install', 1)
{
  $rabbitmq_webserver_restart = true
} else {
  $rabbitmq_webserver_restart = false
}

if hash_key_equals($rabbitmq_values, 'install', 1) {
  if $::osfamily == 'redhat' {
    Class['erlang']
    -> Class['rabbitmq']

    include erlang
  }

  create_resources('class', { 'rabbitmq' => $rabbitmq_values['settings'] })

  if hash_key_equals($php_values, 'install', 1)
    and ! defined(Php::Pecl::Module['amqp'])
  {
    php::pecl::module { 'amqp':
      use_package         => false,
      service_autorestart => $rabbitmq_webserver_restart,
      require             => Class['rabbitmq']
    }
  }

  if ! defined(Firewall['100 tcp/15672']) {
    firewall { '100 tcp/15672':
      port   => 15672,
      proto  => tcp,
      action => 'accept',
    }
  }
}

