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

class wso2base::clean {
  $carbon_home   = $wso2base::carbon_home
  $mode          = $wso2base::maintenance_mode
  $pack_filename = $wso2base::pack_filename
  $pack_dir      = $wso2base::pack_dir

  # TODO: use Puppet RAL instead of commands. In other words, get Puppet to do this!
  case $mode {
    'refresh': {
      exec {
        "remove_lock_file_${carbon_home}":
          path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          onlyif  => "test -f ${carbon_home}/wso2carbon.lck",
          command => "rm ${carbon_home}/wso2carbon.lck",
          notify  =>  Exec["stop_process_${carbon_home}"];

        "stop_process_${carbon_home}":
          path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
          command     => "kill -9 `cat ${carbon_home}/wso2carbon.pid`",
          refreshonly => true;
      }
    }

    'new': {
      exec { "stop_process_and_remove_CARBON_HOME_${carbon_home}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill -9 `cat ${carbon_home}/wso2carbon.pid` && rm -rf ${carbon_home}";
      }
    }

    'zero': {
      exec { "stop_process_remove_CARBON_HOME_and_pack_${carbon_home}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill -9 `cat ${carbon_home}/wso2carbon.pid` && rm -rf ${carbon_home} && rm -f ${pack_dir}/${pack_filename}";
      }
    }

    default: { fail("Clean mode ${mode} is not supported by this module") }
  }
}