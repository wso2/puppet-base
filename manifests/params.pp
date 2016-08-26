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

class wso2base::params {
  $java_class             = 'wso2base::java'
  $java_install_dir       = '/mnt/jdk-7u80'
  $java_source_file       = 'jdk-7u80-linux-x64.tar.gz'
  $java_prefs_system_root = '/home/wso2user/.java'
  $java_prefs_user_root   = '/home/wso2user/.java/.systemPrefs'
  $java_home              = '/opt/java'
  # system configuration data
  $packages               = [
    'zip',
    'unzip'
  ]
  $file_list              = []
  $system_file_list       = []
  $directory_list         = []
  $hosts_mapping          = {
    localhost => {
      ip => '127.0.0.1',
      name => 'localhost'
    }
  }
  $master_datasources     = {
    wso2_carbon_db  => {
      name => 'WSO2_CARBON_DB',
      description => 'The datasource used for registry and user manager',
      driver_class_name => 'org.h2.Driver',
      url => 'jdbc:h2:repository/database/WSO2CARBON_DB;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000',
      username => 'wso2carbon',
      password => 'wso2carbon',
      jndi_config => 'jdbc/WSO2CarbonDB',
      max_active => '50',
      max_wait => '60000',
      test_on_borrow => true,
      default_auto_commit => false,
      validation_query => 'SELECT 1',
      validation_interval => '30000'
    }
  }
  $registry_mounts        = []
  $carbon_home_symlink    = "/mnt/${::product_name}-${::product_version}"
  $wso2_user              = 'wso2user'
  $wso2_group             = 'wso2'
  $maintenance_mode       = 'refresh'
  $install_mode           = 'file_bucket'
  $install_dir            = "/mnt/${::ipaddress}"
  $pack_dir               = '/mnt/packs'
  $pack_filename          = "${::product_name}-${::product_version}.zip"
  $pack_extracted_dir     = "${::product_name}-${::product_version}"
  $hostname               = 'localhost'
  $mgt_hostname           = 'localhost'
  $worker_node            = false
  $patches_dir            = 'repository/components/patches'
  $service_name           = "${::product_name}"
  $service_template       = 'wso2base/wso2service.erb'
  $usermgt_datasource     = 'wso2_carbon_db'
  $local_reg_datasource   = 'wso2_carbon_db'
  $clustering             = {
    enabled => false,
    membership_scheme => 'wka',
    domain => 'wso2.carbon.domain',
    local_member_host => '127.0.0.1',
    local_member_port => '4000',
    sub_domain => 'mgt',
    wka => {
      members => [
        {
          hostname => '127.0.0.1',
          port => 4000
        }
      ]
    }
  }
  $dep_sync               = {
    enabled => false
  }
  $ports                  = {
    offset => 0
  }
  $jvm                    = {
    xms => '256m',
    xmx => '1024m',
    max_perm_size => '256m'
  }
  $ipaddress              = "${::ipaddress}"
  $fqdn                   = "${::fqdn}"
  $sso_authentication     = {
    enabled => false
  }
  $user_management        = {
    admin_role      => 'admin',
    admin_username  => 'admin',
    admin_password  => 'admin'
  }
  $enable_secure_vault    = false
  $secure_vault_configs   = []
  $key_stores             = {
    key_store => {
      location => 'repository/resources/security/wso2carbon.jks',
      type => 'JKS',
      password => 'wso2carbon',
      key_alias => 'wso2carbon',
      key_password => 'wso2carbon'
    },
    registry_key_store => {
      location => 'repository/resources/security/wso2carbon.jks',
      type => 'JKS',
      password => 'wso2carbon',
      key_alias => 'wso2carbon',
      key_password => 'wso2carbon'
    },
    trust_store => {
      location => 'repository/resources/security/client-truststore.jks',
      type => 'JKS',
      password => 'wso2carbon'
    },
    connector_key_store => {
      location => 'repository/resources/security/wso2carbon.jks',
      password => 'wso2carbon'
    },
    user_trusted_rp_store => {
      location => 'repository/resources/security/userRP.jks',
      type => 'JKS',
      password => 'wso2carbon',
      key_password => 'wso2carbon'
    }
  }
}