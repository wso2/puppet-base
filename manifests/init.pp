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
# Class: wso2base
#
# This class installs required system packages for WSO2 products and configures operating system parameters
class wso2base {
  $java_class             = hiera('java_class')
  $java_prefs_system_root = hiera('java_prefs_system_root')
  $java_prefs_user_root   = hiera('java_prefs_user_root')
  $java_home              = hiera('java_home')

  # system configuration data
  $packages             = hiera_array('packages')
  $template_list        = hiera_array('wso2::template_list')
  $file_list            = hiera_array('wso2::file_list')
  $system_file_list     = hiera_array('wso2::system_file_list')
  $directory_list       = hiera_array('wso2::directory_list', [])
  $hosts_mapping        = hiera_hash('wso2::hosts_mapping')

  $master_datasources   = hiera_hash('wso2::master_datasources')
  $registry_mounts      = hiera_hash('wso2::registry_mounts', { })
  $carbon_home_symlink  = hiera('wso2::carbon_home_symlink')
  $wso2_user            = hiera('wso2::user')
  $wso2_group           = hiera('wso2::group')
  $maintenance_mode     = hiera('wso2::maintenance_mode')
  $install_mode         = hiera('wso2::install_mode')
  $install_dir          = hiera('wso2::install_dir')
  $pack_dir             = hiera('wso2::pack_dir')
  $pack_filename        = hiera('wso2::pack_filename')
  $pack_extracted_dir   = hiera('wso2::pack_extracted_dir')
  $hostname             = hiera('wso2::hostname')
  $mgt_hostname         = hiera('wso2::mgt_hostname')
  $worker_node          = hiera('wso2::worker_node')
  $patches_dir          = hiera('wso2::patches_dir')
  $service_name         = hiera('wso2::service_name')
  $service_template     = hiera('wso2::service_template')
  $usermgt_datasource   = hiera('wso2::usermgt_datasource')
  $local_reg_datasource = hiera('wso2::local_reg_datasource')
  $clustering           = hiera('wso2::clustering')
  $dep_sync             = hiera('wso2::dep_sync')
  $ports                = hiera('wso2::ports')
  $jvm                  = hiera('wso2::jvm')
  $ipaddress            = hiera('wso2::ipaddress')
  $fqdn                 = hiera('wso2::fqdn')
  $sso_authentication   = hiera('wso2::sso_authentication')
  $user_management      = hiera('wso2::user_management')
  $enable_secure_vault  = hiera('wso2::enable_secure_vault')
  $key_stores           = hiera('wso2::key_stores')

  $carbon_home          = "${install_dir}/${pack_extracted_dir}"

  if ($enable_secure_vault == true) {
    $secure_vault_configs = hiera('wso2::secure_vault_configs')
    $key_store_password   = $secure_vault_configs['key_store_password']['password']
  }

  # marathon-lb cert configs
  if ($::platform == 'mesos') {
    $marathon_lb_cert_config = hiera('wso2::marathon_lb_cert_config')
    $marathon_lb_cert_config_enabled = $marathon_lb_cert_config['enabled']
    if ($marathon_lb_cert_config_enabled == true){
      $trust_store_password   = $marathon_lb_cert_config['trust_store_password']
      $cert_file = $marathon_lb_cert_config['cert_file']
    }
  }

  class { '::wso2base::system':
    packages         => $packages,
    wso2_group       => $wso2_group,
    wso2_user        => $wso2_user,
    service_name     => $service_name,
    service_template => $service_template,
    hosts_mapping    => $hosts_mapping
  }

  require $java_class
}
