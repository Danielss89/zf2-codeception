if $mysql_values == undef { $mysql_values = hiera('mysql', false) }
if $php_values == undef { $php_values = hiera('php', false) }
if $apache_values == undef { $apache_values = hiera('apache', false) }
if $nginx_values == undef { $nginx_values = hiera('nginx', false) }

include puphpet::params

if hash_key_equals($mysql_values, 'install', 1) {
  include mysql::params

  if hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $mysql_webserver_restart = true
  } else {
    $mysql_webserver_restart = false
  }

  if $::osfamily == 'redhat' {
    $rhel_mysql = 'http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'
    exec { 'mysql-community-repo':
      command => "yum -y --nogpgcheck install '${rhel_mysql}' && touch /.puphpet-stuff/mysql-community-release",
      creates => '/.puphpet-stuff/mysql-community-release'
    }

    $mysql_server_require             = Exec['mysql-community-repo']
    $mysql_server_server_package_name = 'mysql-community-server'
    $mysql_server_client_package_name = 'mysql-community-client'
  } else {
    $mysql_server_require             = []
    $mysql_server_server_package_name = $mysql::params::server_package_name
    $mysql_server_client_package_name = $mysql::params::client_package_name
  }

  if hash_key_equals($php_values, 'install', 1) {
    $mysql_php_installed = true
    $mysql_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $mysql_php_installed = true
    $mysql_php_package   = 'hhvm'
  } else {
    $mysql_php_installed = false
  }

  if $mysql_values['root_password'] {
    class { 'mysql::server':
      package_name  => $mysql_server_server_package_name,
      root_password => $mysql_values['root_password'],
      require       => $mysql_server_require
    }

    class { 'mysql::client':
      package_name => $mysql_server_client_package_name,
      require      => $mysql_server_require
    }

    if is_hash($mysql_values['databases']) and count($mysql_values['databases']) > 0 {
      create_resources(mysql_db, $mysql_values['databases'])
    }

    if $mysql_php_installed and $mysql_php_package == 'php' {
      if $::osfamily == 'redhat' and $php_values['version'] == '53' {
        $mysql_php_module = 'mysql'
      } elsif $::lsbdistcodename == 'lucid' or $::lsbdistcodename == 'squeeze' {
        $mysql_php_module = 'mysql'
      } else {
        $mysql_php_module = 'mysqlnd'
      }

      if ! defined(Php::Module[$mysql_php_module]) {
        php::module { $mysql_php_module:
          service_autorestart => $mysql_webserver_restart,
        }
      }
    }
  }

  if hash_key_equals($mysql_values, 'adminer', 1) and $mysql_php_installed {
    if hash_key_equals($apache_values, 'install', 1) {
      $mysql_adminer_webroot_location = '/var/www/default'
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $mysql_adminer_webroot_location = $puphpet::params::nginx_webroot_location
    } else {
      $mysql_adminer_webroot_location = '/var/www/default'
    }

    class { 'puphpet::adminer':
      location    => "${mysql_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $mysql_php_package
    }
  }
}

define mysql_db (
  $user,
  $password,
  $host,
  $grant    = [],
  $sql_file = false
) {
  if $name == '' or $password == '' or $host == '' {
    fail( 'MySQL DB requires that name, password and host be set. Please check your settings!' )
  }

  mysql::db { $name:
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant,
    sql      => $sql_file,
  }
}

