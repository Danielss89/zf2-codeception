if $mariadb_values == undef { $mariadb_values = hiera('mariadb', false) }
if $php_values == undef { $php_values = hiera('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera('hhvm', false) }
if $apache_values == undef { $apache_values = hiera('apache', false) }
if $nginx_values == undef { $nginx_values = hiera('nginx', false) }

include puphpet::params

if hash_key_equals($mariadb_values, 'install', 1) {
  include mysql::params

  if hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $mariadb_webserver_restart = true
  } else {
    $mariadb_webserver_restart = false
  }

  if hash_key_equals($php_values, 'install', 1) {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'hhvm'
  } else {
    $mariadb_php_installed = false
  }

  if has_key($mariadb_values, 'root_password') and $mariadb_values['root_password'] {
    if ! defined(File[$mysql::params::datadir]) {
      file { $mysql::params::datadir:
        ensure => directory,
        group  => $mysql::params::root_group,
        before => Class['mysql::server']
      }
    }

    if ! defined(Group['mysql']) {
      group { 'mysql':
        ensure => present
      }
    }

    if ! defined(User['mysql']) {
      user { 'mysql':
        ensure => present,
      }
    }

    if (! defined(File['/var/run/mysqld'])) {
      file { '/var/run/mysqld' :
        ensure  => directory,
        group   => 'mysql',
        owner   => 'mysql',
        before  => Class['mysql::server'],
        require => [User['mysql'], Group['mysql']],
        notify  => Service['mysql'],
      }
    }

    if ! defined(File[$mysql::params::socket]) {
      file { $mysql::params::socket :
        ensure  => file,
        group   => $mysql::params::root_group,
        before  => Class['mysql::server'],
        require => File[$mysql::params::datadir]
      }
    }

    if ! defined(Package['mysql-libs']) {
      package { 'mysql-libs':
        ensure => purged,
        before => Class['mysql::server'],
      }
    }

    class { 'puphpet::mariadb':
      version => $mariadb_values['version']
    }

    class { 'mysql::server':
      package_name  => $puphpet::params::mariadb_package_server_name,
      root_password => $mariadb_values['root_password'],
      service_name  => 'mysql',
    }

    class { 'mysql::client':
      package_name => $puphpet::params::mariadb_package_client_name
    }

    if is_hash($mariadb_values['databases'])
      and count($mariadb_values['databases']) > 0
    {
      create_resources(mariadb_db, $mariadb_values['databases'])
    }

    if $mariadb_php_installed and $mariadb_php_package == 'php' {
      if $::osfamily == 'redhat' and $php_values['version'] == '53' {
        $mariadb_php_module = 'mysql'
      } elsif $::lsbdistcodename == 'lucid' or $::lsbdistcodename == 'squeeze' {
        $mariadb_php_module = 'mysql'
      } else {
        $mariadb_php_module = 'mysqlnd'
      }

      if ! defined(Php::Module[$mariadb_php_module]) {
        php::module { $mariadb_php_module:
          service_autorestart => $mariadb_webserver_restart,
        }
      }
    }
  }

  if hash_key_equals($mariadb_values, 'adminer', 1) and $mariadb_php_installed {
    if hash_key_equals($apache_values, 'install', 1) {
      $mariadb_adminer_webroot_location = '/var/www/default'
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $mariadb_adminer_webroot_location = $puphpet::params::nginx_webroot_location
    } else {
      $mariadb_adminer_webroot_location = '/var/www/default'
    }

    class { 'puphpet::adminer':
      location    => "${mariadb_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $mariadb_php_package
    }
  }
}

define mariadb_db (
  $user,
  $password,
  $host,
  $grant    = [],
  $sql_file = false
) {
  if $name == '' or $password == '' or $host == '' {
    fail( 'MariaDB requires that name, password and host be set. Please check your settings!' )
  }

  mysql::db { $name:
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant,
    sql      => $sql_file,
  }
}

