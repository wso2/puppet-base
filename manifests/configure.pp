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

class wso2base::configure {

  $patches_dir          = $wso2base::patches_dir
  $template_list        = $wso2base::template_list
  $file_list            = $wso2base::file_list
  $remove_file_list     = $wso2base::remove_file_list
  $patch_list           = $wso2base::patch_list
  $cert_list            = $wso2base::cert_list
  $system_file_list     = $wso2base::system_file_list
  $carbon_home          = $wso2base::carbon_home
  $wso2_group           = $wso2base::wso2_group
  $wso2_user            = $wso2base::wso2_user
  $platform_version     = $wso2base::platform_version
  $java_home            = $wso2base::java_home
  $key_stores           = $wso2base::key_stores

  # Ensure that patches specified in patch_list are present
  if ($patch_list != undef and size($patch_list) > 0) {
    wso2base::patch {
      $patch_list:
        carbon_home      => $carbon_home,
        patches_dir      => $patches_dir,
        platform_version => $platform_version,
        owner            => $wso2_user,
        group            => $wso2_group,
        wso2_module      => $caller_module_name
    }
  } else {
    # If the patch_list is empty then copy all the patches from Puppet patch files source
    ensure_resource('file', "${carbon_home}/${patches_dir}", {
      ensure  => present,
      owner   => $wso2_user,
      group   => $wso2_group,
      recurse => remote,
      mode    => '0754',
      source  => ["puppet:///modules/${caller_module_name}/patches/${platform_version}"]
    })
  }

  if ($template_list != undef and size($template_list) > 0) {
    wso2base::push_templates {
      $template_list:
        owner       => $wso2_user,
        group       => $wso2_group,
        carbon_home => $carbon_home,
        wso2_module => $caller_module_name
    }
  }

  if ($file_list != undef and size($file_list) > 0) {
    wso2base::push_files {
      $file_list:
        owner       => $wso2_user,
        group       => $wso2_group,
        carbon_home => $carbon_home,
        wso2_module => $caller_module_name
    }
  }

  if ($system_file_list != undef and size($system_file_list) > 0) {
    wso2base::push_system_files {
      $system_file_list:
        owner       => $wso2_user,
        group       => $wso2_group,
        wso2_module => $caller_module_name
    }
  }

  if ($cert_list != undef and size($cert_list) > 0) {
    wso2base::import_cert {
      $cert_list:
        carbon_home          => $carbon_home,
        java_home            => $java_home,
        owner                => $wso2_user,
        group                => $wso2_group,
        wso2_module          => $caller_module_name,
        trust_store_password => $key_stores['trust_store']['password']
    }
  }

  if ($remove_file_list != undef and size(remove_file_list) > 0) {
    wso2base::remove_files {
      $remove_file_list:
        owner       => $wso2_user,
        group       => $wso2_group,
        carbon_home => $carbon_home,
        wso2_module => $caller_module_name,
        require   => [Wso2base::Push_files[$file_list], Wso2base::Push_templates[$template_list]]
    }
  }
}
