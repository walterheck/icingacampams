class profile::base {

  # configure ntp
  class {'ntp':
    package_ensure => 'latest',
  }

  # TODO: this needs to be enabled
  class { 'firewall':
    ensure => stopped,
  }

  # configure ssh
  include ::ssh::client
  include ::ssh::server

  # depending on the OS, include apt or yum repos
  case $::osfamily {
    'debian' : { include profile::base::apt }
    'redhat' : { include profile::base::yum }
    default  : { fail("Unsupported Operating System family : ${::osfamily}") }
  }

  # load other network interfaces from hiera
  $packages = hiera_hash('profile::base::packages', undef)
  if $packages {
    create_resources('package', $packages)
  }

  # apply basic icinga checks to servers
  if $::fqdn != hiera('icingaweb::fqdn') {
    include profile::icinga::client
    include profile::base::icinga
  }

  $rand1 = fqdn_rand(30)
  $rand2 = $rand1 + 30

  cron { 'Puppet agent run':
    command => '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize',
    user    => 'root',
    minute  => [ $rand1, $rand2],
  }

}
