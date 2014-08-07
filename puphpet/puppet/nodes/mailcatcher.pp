if $mailcatcher_values == undef { $mailcatcher_values = hiera('mailcatcher', false) }

include puphpet::params
include puphpet::supervisord

if hash_key_equals($mailcatcher_values, 'install', 1) {
  if ! defined(Package['tilt']) {
    package { 'tilt':
      ensure   => '1.3',
      provider => 'gem',
      before   => Class['mailcatcher']
    }
  }

  if $::operatingsystem == 'ubuntu' and $lsbdistcodename == 'trusty' {
    package { 'rubygems':
      ensure => absent,
    }
  }

  create_resources('class', { 'mailcatcher' => $mailcatcher_values['settings'] })

  if ! defined(Firewall["100 tcp/${mailcatcher_values['settings']['smtp_port']}, ${mailcatcher_values['settings']['http_port']}"]) {
    firewall { "100 tcp/${mailcatcher_values['settings']['smtp_port']}, ${mailcatcher_values['settings']['http_port']}":
      port   => [$mailcatcher_values['settings']['smtp_port'], $mailcatcher_values['settings']['http_port']],
      proto  => tcp,
      action => 'accept',
    }
  }

  $mailcatcher_path = $mailcatcher_values['settings']['mailcatcher_path']

  $mailcatcher_options = sort(join_keys_to_values({
    ' --smtp-ip'   => $mailcatcher_values['settings']['smtp_ip'],
    ' --smtp-port' => $mailcatcher_values['settings']['smtp_port'],
    ' --http-ip'   => $mailcatcher_values['settings']['http_ip'],
    ' --http-port' => $mailcatcher_values['settings']['http_port']
  }, ' '))

  supervisord::program { 'mailcatcher':
    command     => "${mailcatcher_path}/mailcatcher ${mailcatcher_options} -f",
    priority    => '100',
    user        => 'mailcatcher',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${mailcatcher_path}"
    },
    require => [
      Class['mailcatcher::config'],
      File['/var/log/mailcatcher']
    ],
  }
}

