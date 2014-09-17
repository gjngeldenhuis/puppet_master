class puppet_master::mom (
) {

  class { 'puppet_master::pe_httpd':
    ca_enabled => true,
  }

  file { '/etc/puppetlabs/puppet/auth.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/puppet_master/auth.conf',
  }
}
