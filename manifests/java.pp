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
class wso2base::java (
  $deploymentdir     = '/mnt/jdk-7u80',
  $source            = 'jdk-7u80-linux-x64.tar.gz',
  $java_home         = '/opt/java',
  $user              = 'root',
  $cachedir          = '/opt/java-setup',
  $ensure            = 'present',
  $remove_cachedir   = false,
  $pathfile          = '/etc/bashrc'
) {

  case $::osfamily {
    'Debian'  : { $supported = true }
    'RedHat'  : { $supported = true }
    'Suse'    : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }

  # Validate parameters
  validate_string($source)
  validate_string($user)
  validate_string($ensure)
  validate_bool($remove_cachedir)

  # Validate source is .gz or .tar.gz
  if !(('.tar.gz' in $source) or ('.gz' in $source) or ('.bin' in $source)) {
    fail('source must be either .tar.gz or .gz or .bin')
  }

  # Validate input values for $ensure
  if !($ensure in ['present', 'absent']) {
    fail('ensure must either be present or absent')
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

  # Install java only when ensure => present
  if ($ensure == 'present') {

    $install_dirs = [$deploymentdir, $cachedir]
    ensure_resource('file', $install_dirs, {
      ensure  => 'directory'
    })

    file { "${cachedir}/${source}":
      source  => [
        "puppet:///modules/${mod_name}/${source}",
        "puppet:///files/packs/${source}"
      ],
      mode    => '0711',
      require => File[$install_dirs],
    }

    if ('.bin' in $source) {
      exec { "extract_java-${name}":
        cwd     => $cachedir,
        command => "mkdir extracted; cd extracted ;  ../*.bin  <> echo '\n\n' -d extracted && touch ${cachedir}/.java_extracted",
        creates => "${cachedir}/.java_extracted",
        # in case of a bin archive, we get a return code of 1 from unzip. This is ok
        returns => [0, 1],
        require => File["${cachedir}/${source}"],
      }
    } else {
      exec { "extract_java-${name}":
        cwd     => $cachedir,
        command => "mkdir extracted; tar -C extracted -xzf *.gz && touch ${cachedir}/.java_extracted",
        creates => "${cachedir}/.java_extracted",
        require => File["${cachedir}/${source}"],
      }
    }

    exec { "create_target-${name}":
      cwd     => '/',
      command => "mkdir -p ${deploymentdir}",
      creates => $deploymentdir,
      require => Exec["extract_java-${name}"],
    }

    exec { "move_java-${name}":
      cwd     => "${cachedir}/extracted",
      command => "cp -r */* ${deploymentdir}/ && chown -R ${user}:${user} ${deploymentdir} && touch ${deploymentdir}/.puppet_java_${name}_deployed",
      creates => "${deploymentdir}/.puppet_java_${name}_deployed",
      require => Exec["create_target-${name}"],
    }

    exec { "set_java_home-${name}":
      cwd     => '/',
      command => "echo 'export JAVA_HOME=${deploymentdir}' >> ${pathfile}",
      unless  => "grep 'JAVA_HOME=${deploymentdir}' ${pathfile}",
      require => Exec["move_java-${name}"],
    }

    exec { "update_path-${name}":
      cwd     => '/',
      command => "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> ${pathfile}",
      unless  => "grep 'export PATH=\$JAVA_HOME/bin:\$PATH' ${pathfile}",
      require => Exec["set_java_home-${name}"],
    }

    exec { "update_classpath-${name}":
      cwd     => '/',
      command => "echo 'export CLASSPATH=\$JAVA_HOME/lib/classes.zip' >> ${pathfile}",
      unless  => "grep 'export CLASSPATH=\$JAVA_HOME/lib/classes.zip' ${pathfile}",
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

    if $remove_cachedir {
      file { $cachedir:
        ensure  => absent,
        recurse => true,
        force   => true,
        require => Exec["move_java-${name}"]
      }
    }

  } else {
    file { $deploymentdir:
      ensure  => absent,
      recurse => true,
      force   => true,
    }

    file { $cachedir:
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }
}
