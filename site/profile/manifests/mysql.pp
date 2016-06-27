class profile::mysql {
  include ::mysql::client

  $override_options = hiera_hash('profile::mysql::override_options', undef)

  class { '::mysql::server':
      package_ensure   => 'present',
      override_options => $override_options,
  }

  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-percona':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/opstheater/mysql/RPM-GPG-KEY-percona',
    before => [ Package['mysql_client'], Class['::mysql::server'] ],
  }

  file { '/var/log/mysql':
    ensure => 'directory',
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0755',
  }

  package { [ 'percona-toolkit', 'percona-xtrabackup' ]:
    ensure => latest,
  }

}
