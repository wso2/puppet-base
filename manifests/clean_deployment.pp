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

# check the pack against the latest pack in the puppet master and do cleanup if necessary 
define wso2base::clean_deployment ($pack_file_abs_path, $caller_module_name, $pack_filename, $user, $group, $install_dir, $pack_dir) {
    $temp_pack_file_abs_path = "/tmp/${pack_filename}"
    $install_dirs = [ $install_dir, $pack_dir ]

    # download the current pack exists in the puppet master to temporary location
    file { "${temp_pack_file_abs_path}":
        ensure         => present,
        source         => ["puppet:///modules/${caller_module_name}/${pack_filename}", "puppet:///files/packs/${pack_filename}"],
        replace        => true,
        notify         => Exec['check_diff']
    }

    # if there is a difference between the current pack and the new pack, remove the current pack and the deployment
    exec { 'check_diff':
        provider       => shell,
        command        => "if [ -f `${carbon_home}/wso2carbon.pid`]; then kill -9 `cat ${carbon_home}/wso2carbon.pid`; fi && wait && rm -rf ${pack_dir}/* ${carbon_home}",
        path           => ['/usr/bin', '/usr/sbin', '/bin'],
        onlyif         => "test `diff -q ${pack_file_abs_path} ${temp_pack_file_abs_path} >/dev/null; echo $?` -eq 1",
        refreshonly    => true,
        notify         => Exec['clean_temp_pack']
    }

    # remove the temporary packs
    exec { 'clean_temp_pack':
        command        => "rm ${temp_pack_file_abs_path}",
        path           => ['/usr/bin', '/usr/sbin', '/bin'],
        onlyif         => "test -f ${temp_pack_file_abs_path}",
        refreshonly    => true
    }
}
