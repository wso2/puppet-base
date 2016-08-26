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

define wso2base::start (
  $service_name,
  $install_dir
) {
  $carbon_home        = "${install_dir}/${::product_name}-${::product_version}"
  # Start the service
  # TODO: start the service only if configuration changes are applied that needs a restart to be effective
  if $::vm_type != 'docker' {
    service { $service_name:
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true
    }

    notify { "Successfully started WSO2 service [name] ${service_name}, [CARBON_HOME] ${carbon_home}":
      withpath => true,
      require  => Service[$service_name]
    }
  }
}