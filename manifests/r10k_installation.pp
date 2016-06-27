exec { 'create-ssh-key':
  command => 'yes y | ssh-keygen -t dsa -C "r10k" -f /root/.ssh/id_dsa -q -N ""',
  path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  creates => '/root/.ssh/id_dsa.pub',
} ->

#https://docs.puppetlabs.com/references/latest/type.html#sshkey
sshkey { 'github.com':
  ensure => present,
  type   => 'ssh-rsa',
  target => '/root/.ssh/known_hosts',
  key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
} ->

class { 'r10k':
  version    => '2.0.3',
  configfile => '/etc/puppetlabs/r10k/r10k.yaml',
  sources    => {
    'puppet' => {
      'remote'  => 'https://github.com/walterheck/icingacampams.git',
      'basedir' => $::settings::environmentpath,
      'prefix'  => false,
    }
  },
}
