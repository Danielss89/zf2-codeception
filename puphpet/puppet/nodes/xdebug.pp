if $xdebug_values == undef { $xdebug_values = hiera('xdebug', false) }
if $php_values == undef { $php_values = hiera('php', false) }
if $apache_values == undef { $apache_values = hiera('apache', false) }
if $nginx_values == undef { $nginx_values = hiera('nginx', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1) {
  $xdebug_webserver_service = 'httpd'
} elsif hash_key_equals($nginx_values, 'install', 1) {
  $xdebug_webserver_service = 'nginx'
} else {
  $xdebug_webserver_service = undef
}

if hash_key_equals($xdebug_values, 'install', 1)
  and hash_key_equals($php_values, 'install', 1)
{
  $xdebug_compile = $php_values['version'] ? {
    '5.6'   => true,
    '56'    => true,
    default => false,
  }

  class { 'puphpet::php::xdebug':
    webserver => $xdebug_webserver_service,
    compile   => $xdebug_compile,
  }

  if is_hash($xdebug_values['settings']) and count($xdebug_values['settings']) > 0 {
    each( $xdebug_values['settings'] ) |$key, $value| {
      puphpet::php::ini { $key:
        entry       => "XDEBUG/${key}",
        value       => $value,
        php_version => $php_values['version'],
        webserver   => $xdebug_webserver_service
      }
    }
  }
}

