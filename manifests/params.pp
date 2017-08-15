#----------------------------------------------------------------------------
#  Copyright (c) 2017 WSO2, Inc. http://www.wso2.org
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

  # use_hieradata facter flags whether parameter lookup should be done via Hiera
  if $::use_hieradata == 'true' {

    # server startup script name
    $startup_script_name      = hiera('wso2::startup_script_name')
    # whether we automatically start wso2service or not
    $autostart_service        = hiera('wso2::autostart_service')
    # java properties
    $install_java             = hiera('wso2::java::install')
    $java_install_dir         = hiera('wso2::java::installation_dir')
    $java_source_file         = hiera('wso2::java::source_file')
    $java_user                = hiera('wso2::java::user')
    $java_group               = hiera('wso2::java::group')

  } else {

    # whether we automatically start wso2service or not
    $autostart_service        = true
    # java properties
    $install_java             = true
    $java_install_dir         = '/mnt/jdk-8u131'
    $java_source_file         = 'jdk-8u131-linux-x64.tar.gz'
    $java_user                = 'wso2user'
    $java_group               = 'wso2'
  }

  validate_bool($autostart_service)
  validate_bool($install_java)
  validate_string($java_install_dir)
  validate_string($java_source_file)
  validate_string($java_user)
  validate_string($java_group)
}
