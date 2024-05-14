# Upgrade Guide: Ubuntu 18.04 LTS to Ubuntu 22.04 LTS

This README file provides step-by-step instructions for upgrading from Ubuntu 18.04 LTS to Ubuntu 22.04 LTS. Follow the steps below to safely and successfully upgrade your system:

<p align="center">
<img src=ubuntu-logo.png width="250"/>
</p>

1. **Backup**: Back up important data and configurations.
2. **Pre-Upgrade Checklist**: Check system readiness and requirements.
3. **Prepare TCP Port 1022**: Prepare a secondary SSH port.
4. **Upgrade the System**: Upgrade the system using the `sudo do-release-upgrade` command.
5. **Restart the System**: Restart the system after the upgrade process is completed.
6. **Remove Firewall Rule**: Remove the firewall rule for port 1022.

7. **References**:
  
    - [Ubuntu Release](https://github.com/canonical/subiquity/releases)
    - [How to upgrade](https://ubuntu.com/server/docs/how-to-upgrade-your-release)
    - [Mirror List](http://tr.archive.ubuntu.com/ubuntu)
    - [Upgrading from Ubuntu 18.04 LTS to 22.04 LTS](https://medium.com/@BabajideKale/upgrading-from-ubuntu-18-04-lts-to-22-04-lts-adf5f4a54ffa)
    - [How to Upgrade from Ubuntu 22.04 LTS to Ubuntu 24.04 LTS](https://jumpcloud.com/blog/how-to-upgrade-ubuntu-22-04-to-ubuntu-24-04)
