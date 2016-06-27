exec { 'create-ssh-key':
  command => 'yes y | ssh-keygen -t dsa -C "r10k" -f /root/.ssh/id_dsa -q -N ""',
  path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  creates => '/root/.ssh/id_dsa.pub',
} ->

#https://docs.puppetlabs.com/references/latest/type.html#sshkey
sshkey { 'github.com':
  ensure => present,
  type   => 'ecdsa-sha2-nistp256',
  target => '/root/.ssh/known_hosts',
  key    => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDw3fj8seCnMtJTnNSehf+Fl1xlCtgP3GOcwjSTZHHt7wHdip32C9PplZtNej+t1LWSmaW41JNyNxlSoYer1Kys='
} ->

class { 'r10k':
  version    => '2.0.3',
  configfile => '/etc/puppetlabs/r10k/r10k.yaml',
  sources    => {
    'puppet' => {
      'remote'  => 'https://gitlab.olindata.com/opstheater/opstheater.git',
      'basedir' => $::settings::environmentpath,
      'prefix'  => false,
    }
  },
}
