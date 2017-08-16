# ------------------------------------------------------------------------------
# Copyright (c) 2016, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

class wso2base::service {

  $vm_type           = $wso2base::vm_type
  $service_name      = $wso2base::service_name
  $install_dir       = $wso2base::install_dir
  $carbon_home       = $wso2base::carbon_home
  $autostart_service = $wso2base::autostart_service
  $service_refresh_file_list = $wso2base::service_refresh_file_list

  if ($service_refresh_file_list != undef and size($service_refresh_file_list) > 0) {
    wso2base::push_files {
      $service_refresh_file_list:
        owner       => $wso2_user,
        group       => $wso2_group,
        carbon_home => $carbon_home,
        wso2_module => $caller_module_name
    }
  }

  # Start the service
  if ($vm_type != 'docker') and ($autostart_service) {
    service { $service_name:
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => Wso2base::Push_files[$service_refresh_file_list]
    }

    notify { "Successfully started WSO2 service [name] ${service_name}, [CARBON_HOME] ${carbon_home}":
      withpath => true,
      require  => Service[$service_name]
    }
  }
}
