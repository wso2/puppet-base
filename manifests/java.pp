#----------------------------------------------------------------------------
#  Copyright (c) 2016 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------
#
# Class to manage Java installation
define wso2base::java ($deploymentdir, $source, $java_home, $user, $group) {

  case $::osfamily {
    'Debian'  : { $supported = true }
    'RedHat'  : { $supported = true }
    'Suse'    : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }

  # Validate parameters
  validate_string($source)
  validate_string($user)
  validate_string($group)
  validate_string($deploymentdir)
  validate_string($java_home)

  # Validate source is .gz or .tar.gz
  if !(('.tar.gz' in $source) or ('.gz' in $source) or ('.bin' in $source)) {
    fail('source must be either .tar.gz or .gz or .bin')
  }

  if ($caller_module_name == undef) {
    $mod_name = $module_name
  } else {
    $mod_name = $caller_module_name
  }

  # Resource default for Exec
  Exec {
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
  }

  $install_dirs = [$deploymentdir, '/opt/java-setup']
  ensure_resource('file', $install_dirs, {
    ensure  => 'directory'
  })

  file { "/opt/java-setup/${source}":
    source  => [
      "puppet:///modules/${mod_name}/${source}",
      "puppet:///files/packs/${source}"
    ],
    mode    => '0711',
    require => File[$install_dirs],
  }

  if ('.bin' in $source) {
    exec { "extract_java-${name}":
      cwd     => '/opt/java-setup',
      command => "mkdir extracted; cd extracted ;  ../*.bin  <> echo '\n\n' -d extracted && touch /opt/java-setup/.java_extracted",
      creates => "/opt/java-setup/.java_extracted",
      # in case of a bin archive, we get a return code of 1 from unzip. This is ok
      returns => [0, 1],
      require => File["/opt/java-setup/${source}"],
    }
  } else {
    exec { "extract_java-${name}":
      cwd     => '/opt/java-setup',
      command => "mkdir extracted; tar -C extracted -xzf *.gz && touch /opt/java-setup/.java_extracted",
      creates => "/opt/java-setup/.java_extracted",
      require => File["/opt/java-setup/${source}"],
    }
  }

  exec { "create_target-${name}":
    cwd     => '/',
    command => "mkdir -p ${deploymentdir}",
    creates => $deploymentdir,
    require => Exec["extract_java-${name}"],
  }

  exec { "move_java-${name}":
    cwd     => "/opt/java-setup/extracted",
    command => "cp -r */* ${deploymentdir}/ && chown -R ${user}:${group} ${deploymentdir} && touch ${deploymentdir}/.puppet_java_${name}_deployed",
    creates => "${deploymentdir}/.puppet_java_${name}_deployed",
    require => Exec["create_target-${name}"],
  }

  exec { "set_java_home-${name}":
    cwd     => '/',
    command => "echo 'export JAVA_HOME=${java_home}' >> /etc/.bashrc",
    unless  => "grep 'JAVA_HOME=${java_home}' /etc/.bashrc",
    require => Exec["move_java-${name}"],
  }

  exec { "update_path-${name}":
    cwd     => '/',
    command => "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> /etc/.bashrc",
    unless  => "grep 'export PATH=\$JAVA_HOME/bin:\$PATH' /etc/.bashrc",
    require => Exec["set_java_home-${name}"],
  }

  exec { "update_classpath-${name}":
    cwd     => '/',
    command => "echo 'export CLASSPATH=\$JAVA_HOME/lib/classes.zip' >> /etc/.bashrc",
    unless  => "grep 'export CLASSPATH=\$JAVA_HOME/lib/classes.zip' /etc/.bashrc",
    require => Exec["set_java_home-${name}"],
  }

  # create a symlink for Java deployment
  file { $java_home:
    ensure  => 'link',
    target  => $deploymentdir,
    require => Exec["update_classpath-${name}"]
  }

  # set JAVA_HOME environment variable and include JAVA_HOME/bin in PATH for all users
  file { '/etc/profile.d/set_java_home.sh':
    ensure  => present,
    content => inline_template("JAVA_HOME=${java_home}\nPATH=${java_home}/bin:\$PATH"),
    require => File[$java_home]
  }
}
