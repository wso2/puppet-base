# WSO2 Puppet Base Module

WSO2 base puppet module provides features for installing and configuring WSO2 middleware products.
On high level it includes following:

- Install Java Runtime
- Clean CARBON_HOME directory
- Download and extract WSO2 product distribution
- Apply Carbon Kernel and WSO2 product patches
- Apply configuration data
- Start WSO2 server as a service or in foreground

#### System Service Re-starts

The system service will only restart for distribution changes or configuration changes.

## Supported Operating Systems

- Debian 6 or higher
- Ubuntu 12.04 or higher

## Supported Puppet Versions

- Puppet 2.7, 3 or newer

## How to Contribute
Follow the steps mentioned in [puppet-common](https://github.com/wso2/puppet-common/) repository to setup a development environment and update existing or implement new puppet modules.

