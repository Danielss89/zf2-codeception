if $hhvm_values == undef { $hhvm_values = hiera('hhvm', false) }
if $apache_values == undef { $apache_values = hiera('apache', false) }
if $nginx_values == undef { $nginx_values = hiera('nginx', false) }

include puphpet::params
include puphpet::supervisord

if hash_key_equals($hhvm_values, 'install', 1) {
  if hash_key_equals($apache_values, 'install', 1) {
    $hhvm_webserver         = 'httpd'
    $hhvm_webserver_restart = true
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    $hhvm_webserver         = 'nginx'
    $hhvm_webserver_restart = true
  } else {
    $hhvm_webserver         = undef
    $hhvm_webserver_restart = true
  }

  class { 'puphpet::hhvm':
    nightly   => $hhvm_values['nightly'],
    webserver => $hhvm_webserver
  }

  if ! defined(User['hhvm']) {
    user { 'hhvm':
      home       => '/home/hhvm',
      groups     => 'www-data',
      ensure     => present,
      managehome => true,
      require    => Group['www-data']
    }
  }

  $supervisord_hhvm_cmd = "hhvm --mode server -vServer.Type=fastcgi -vServer.Port=${hhvm_values['settings']['port']}"

  supervisord::program { 'hhvm':
    command     => $supervisord_hhvm_cmd,
    priority    => '100',
    user        => 'hhvm',
    autostart   => true,
    autorestart => 'true',
    environment => { 'PATH' => '/bin:/sbin:/usr/bin:/usr/sbin' },
    require     => [
      User['hhvm'],
      Package['hhvm']
    ]
  }

  file { '/usr/bin/php':
    ensure  => 'link',
    target  => '/usr/bin/hhvm',
    require => Package['hhvm']
  }

  if hash_key_equals($hhvm_values, 'composer', 1)
    and ! defined(Class['puphpet::php::composer'])
  {
    class { 'puphpet::php::composer':
      php_package   => 'hhvm',
      composer_home => $hhvm_values['composer_home'],
    }
  }

  if count($hhvm_values['modules']['pear']) > 0 {
    hhvm_pear_mod { $hhvm_values['modules']['pear']:; }
  }
}

define hhvm_pear_mod {
  if ! defined(Puphpet::Php::Pear[$name]) {
    puphpet::php::pear { $name:
      service_name        => $hhvm_webserver,
      service_autorestart => $hhvm_webserver_restart,
    }
  }
}

