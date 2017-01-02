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

# Downloads the pack, extract and set user permissions
class wso2base::install {

  $wso2_group          = $wso2base::wso2_group
  $wso2_user           = $wso2base::wso2_user
  $vm_type             = $wso2base::vm_type
  $mode                = $wso2base::install_mode
  $install_dir         = $wso2base::install_dir
  $pack_filename       = $wso2base::pack_filename
  $pack_dir            = $wso2base::pack_dir
  $carbon_home_symlink = $wso2base::carbon_home_symlink
  $carbon_home         = $wso2base::carbon_home
  $pack_file_abs_path  = $wso2base::pack_file_abs_path
  $remote_file_url     = $wso2base::remote_file_url
  $directory_list      = $wso2base::directory_list

  # create directories for installation if they do not exist
  $install_dirs=[$install_dir, $pack_dir]
  wso2base::ensure_directory_structures {
    $install_dirs:
      system      => true,
      carbon_home => $carbon_home,
      owner       => $wso2_user,
      group       => $wso2_group
  }

  # create required directories inside CARBON_HOME
  if ($directory_list != undef and size($directory_list) > 0) {
    wso2base::ensure_directory_structures {
      $directory_list:
        system      => false,
        carbon_home => $carbon_home,
        owner       => $wso2_user,
        group       => $wso2_group
    }
  }

  wso2base::clean_deployment { 
    'clean_on_pack_change': 
      pack_file_abs_path => $pack_file_abs_path,
      caller_module_name => $caller_module_name,
      pack_filename      => $pack_filename,
      user               => $wso2_user,
      group              => $wso2_group,
      install_dir        => $install_dir,
      pack_dir           => $pack_dir
  }

  # download wso2 product pack zip archive
  case $mode {
    'file_repo': {
      ensure_resource('exec', $pack_file_abs_path, {
        path           => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        cwd            => $pack_dir,
        command        => "wget -q ${remote_file_url}",
        logoutput      => 'on_failure',
        creates        => $pack_file_abs_path,
        onlyif         => "test -f ${pack_file_abs_path}",
        timeout        => 0,
        notify         => Exec["extract_${pack_file_abs_path}"],
        require        => Wso2base::Ensure_directory_structures[$install_dirs]
      })
    }

    'file_bucket': {
      file { $pack_file_abs_path:
        ensure         => present,
        owner          => $wso2_user,
        group          => $wso2_group,
        mode           => 750,
        source         => [
          "puppet:///modules/${caller_module_name}/${pack_filename}", 
          "puppet:///files/packs/${pack_filename}"
        ],
        require        => Wso2base::Clean_deployment['clean_on_pack_change'],
        notify         => Exec["extract_${pack_file_abs_path}"],
        replace        => true
      }
    }

    default: { fail("Install mode ${mode} is not supported by this module.") }
  }

  # extract downloaded wso2 product pack archive
  ensure_resource('exec', "extract_${pack_file_abs_path}", {
    path               => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd                => $install_dir,
    command            => "unzip ${pack_file_abs_path}",
    logoutput          => 'on_failure',
    creates            => "${carbon_home}/bin",
    timeout            => 0,
    refreshonly        => true,
    notify             => Exec["set_ownership_${carbon_home}"]
  })

  # set ownership for carbon_home
  ensure_resource('exec', "set_ownership_${carbon_home}", {
    path               => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd                => $carbon_home,
    command            => "chown -R ${wso2_user}:${wso2_group} ${install_dir}",
    logoutput          => 'on_failure',
    timeout            => 0,
    refreshonly        => true,
    notify             => Exec["set_permissions_${carbon_home}"]
  })

  # set file permissions for carbon_home
  ensure_resource('exec', "set_permissions_${carbon_home}", {
    path               => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd                => $carbon_home,
    command            => "chmod -R 754 ${install_dir}",
    logoutput          => 'on_failure',
    timeout            => 0,
    refreshonly        => true
  })

  if $vm_type == 'docker' {
    # Remove wso2 product pack zip archive when provisioning the Docker image
    # We are going to re-use the zip archive in non-Docker scenarios to minimize network traffic (for eg. AWS-EC2)
    exec { "remove_product_pack_${carbon_home}":
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      command => "rm -rf ${pack_file_abs_path}",
      require =>  Exec["set_permissions_${carbon_home}"]
    }
  } else {
    # Create a symlink which has ipaddress in the path as a workaround for H2 local database clustering issue
    # This should not happen in Docker scenarios since runtime ipaddress differs from provisioning stage
    file { $carbon_home_symlink:
      ensure => 'link',
      target => $carbon_home
    }
  }
}
