class profile::icinga::web {

  $icinga2_web_fqdn = hiera('icingaweb::fqdn')
  $icinga2_db_fqdn = hiera('icingaweb::mysql_fqdn')

  $icinga2_db_ipaddress = hiera('icingaweb::mysql_ipaddress')
  $icinga2_webdb_password = hiera('icingaweb::webdb_password')
  $icinga2_ido_password = hiera('icinga::ido_password')

  if ! defined (Class['epel']) {
    class { 'epel': }
  }

  class { '::mysql::client': }

  class { 'apache':
  }

  ::apache::listen { '80':
    before => Class['icingaweb2::config'],
  }

  class { 'apache::mod::php': }

  package { 'php-Icinga':
    ensure  => latest,
    require => [ Class['icingaweb2::preinstall'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias   => 'php-Icinga'
  }

  package { 'icingacli':
    ensure  => latest,
    require => [ Class['icingaweb2::preinstall'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias   => 'icingacli'
  }

  package { ['php-ZendFramework', 'php-ZendFramework-Db-Adapter-Pdo-Mysql']:
    ensure  => latest,
    require => Class['epel']
  } ->

  class { 'icingaweb2':
    manage_repo         => true,
    install_method      => 'package',
    manage_apache_vhost => true,
    apache_vhost_name   => $icinga2_web_fqdn,
    ido_db              => 'mysql',
    ido_db_host         => $icinga2_db_ipaddress,
    ido_db_name         => 'icinga2_data',
    ido_db_user         => 'icinga2',
    ido_db_pass         => $icinga2_ido_password,
    ido_db_port         => '3306',
    web_db              => 'mysql',
    web_db_name         => 'icinga2_web',
    web_db_host         => $icinga2_db_ipaddress,
    web_db_user         => 'icinga2_web',
    web_db_pass         => $icinga2_webdb_password,
    web_db_port         => '3306',
  }

  exec { 'populate-icinga2_web-mysql-db':
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => "[ `mysql -h ${icinga2_db_ipaddress} -uicinga2_web -p${icinga2_webdb_password} icinga2_web -ABN -e 'select 1 from icingaweb_user limit 1'` -eq 1 ]",
    command => "mysql -h ${icinga2_db_ipaddress} -uicinga2_web -p${icinga2_webdb_password} icinga2_web < /usr/share/doc/icingaweb2/schema/mysql.schema.sql; mysql -h ${icinga2_db_ipaddress} -uicinga2_web -p${icinga2_webdb_password} icinga2_web -e \"INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\'icingaadmin\', 1, \'\\\$1\\\$iQSrnmO9\\\$T3NVTu0zBkfuim4lWNRmH.\');\"",
    require => [ Class['::mysql::client'], Package['icingaweb2'] ],
  } ->

  file { '/etc/icingaweb2/enabledModules/monitoring':
    ensure => 'link',
    target => '/usr/share/icingaweb2/modules/monitoring',
  }

  file { '/etc/icingaweb2/modules/monitoring':
    ensure => 'directory',
    mode   => '2770',
    owner  => 'root',
    group  => 'icingaweb2',
  }

  file { '/etc/icingaweb2/modules/monitoring/backends.ini':
    ensure  => 'file',
    mode    => '0770',
    owner   => 'root',
    group   => 'icingaweb2',
    content => "[icinga2]\ntype = \"ido\"\nresource = \"icinga_ido\"\n",
  }

  file { '/etc/icingaweb2/groups.ini':
    ensure  => 'file',
    mode    => '0770',
    owner   => 'root',
    group   => 'icingaweb2',
    content => "[icingaweb2]\nresource = \"icingaweb_db\"\nbackend = \"db\"\n",
  }

  file { '/etc/icingaweb2/modules/monitoring/config.ini':
    ensure  => 'file',
    mode    => '0770',
    owner   => 'root',
    group   => 'icingaweb2',
    content => "[security]\nprotected_customvars = \"*pw*,*pass*,community\"\n",
  }

  file { '/etc/icingaweb2/modules/monitoring/commandtransports.ini':
    ensure  => 'file',
    mode    => '0770',
    owner   => 'root',
    group   => 'icingaweb2',
    content => "[icinga2]\ntransport = \"local\"\npath = \"/var/run/icinga2/cmd/icinga2.cmd\"\n",
  }

  ini_setting { 'set icinga php timezone':
    ensure  => present,
    path    => '/etc/php.ini',
    section => 'Date',
    setting => 'date.timezone',
    value   => '"UTC"',
  }

}
