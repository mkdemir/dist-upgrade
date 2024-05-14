# Steps to Upgrade from Ubuntu 18.04 LTS to Ubuntu 22.04 LTS

**Note:** Ubuntu supports upgrading from one LTS (Long Term Support) release to another in sequential order. For example, a user on Ubuntu 16.04 LTS can upgrade to Ubuntu 18.04 LTS but cannot skip directly to Ubuntu 20.04 LTS. To do so, the user must first upgrade to Ubuntu 18.04 LTS and then to Ubuntu 20.04 LTS.

## Steps

### 1. Backup

As always, backup important data and configurations on the system. Upgrades can sometimes lead to unexpected issues.

```bash
sudo rsync -a --progress /home/your_username /path_to_backup_location/home_backup

sudo rsync -a –progress /etc /path_to_backup_location/etc_backup
```

### 2. Pre-Upgrade Checklist

- **Update System:** Ensure that the system has all the latest updates applied, as upgrading works best when the system is fully up-to-date. Also, reboot the system to ensure it's running the latest kernel.

  ```bash
  sudo apt update
  sudo apt upgrade
  sudo reboot
  ```

- **Check Disk Space:** Verify if there is enough disk space available for the upgrade. Upgrading a system will likely involve downloading new packages consisting of hundreds of megabytes. Systems with additional software installed may require several gigabytes of free disk space.

- **`sudo apt dist-upgrade`:** This command upgrades the current packages on the system and installs new packages or removes existing ones as necessary. It manages package dependencies more aggressively, allowing for the removal or addition of packages when needed.

  ```bash
  sudo apt dist-upgrade
  ```

- **Third-Party Software Repositories and PPAs:** Third-party software repositories and Personal Package Archives (PPAs) are disabled during the upgrade. However, software installed from these repositories will not be removed or downgraded. Software installed from these repositories is one of the most common causes of upgrade issues.

- **Remove Unused Packages:** Identify and remove any dependencies that are no longer needed on the system. This prevents the accumulation of unnecessary files and frees up disk space.

  ```bash
  ls -l /etc/apt/sources.list.d/ # Use this command to view the repositories
  sudo apt autoremove –purge
  ```

- **Document Installed Software:** Create a list of all installed packages on the current system and keep this list for post-upgrade verification.

  ```bash
  dpkg --get-selections | grep -v deinstall | awk '{print $1}' > installed-software.txt
  ```

- **Reinstall Packages:** This way, we have a record of all packages installed, and we can reinstall them later if needed.

    ```bash
    sudo dpkg –set-selections < installed-software.txt
    sudo apt-get dselect-upgrade
    ```

**Note:** It's advisable to perform this after completing the upgrade process.

Feel free to add sections you'd like to include in your document, like the one below:

---

### 3. Prepare TCP Port 1022

**Note:** Using a bastion (jump) host is the best practice for security to minimize your attack surface.

The default port for SSH connections is 22. During the upgrade process, SSH configuration might have been altered or misconfigured, making the default SSH service inaccessible. Setting port 1022 as a secondary SSH port is important to address potential issues on the default port during the upgrade and to ensure remote access.

First, let's allow this specific port on the Ubuntu firewall:

```bash
sudo ufw allow 1022/tcp
```

To enforce the rule, run the following command:

```bash
sudo ufw reload
```

Finally, you can verify that the ports are listed properly:

```bash
sudo ufw status
```

### 4. Upgrade the System

**Using the do-release-upgrade Command:** We recommend upgrading the system using the `do-release-upgrade` command on server installations and cloud images. This command can handle necessary system configuration changes that may be required between releases.

#### The `sudo do-release-upgrade` Command

1. **Running the Command**:

   ```bash
   sudo do-release-upgrade
   ```

2. **Upgrade Process**:
   - Upon running the command, the system checks for a new Ubuntu release.
   - If a new release is found, it downloads and verifies the upgrade tool.

   ```plaintext
   root@ubuntu:~# sudo do-release-upgrade
   Checking for a new Ubuntu release
   Get:1 Upgrade tool signature [1,554 B]
   Get:2 Upgrade tool [1,338 kB]
   Fetched 1,340 kB in 0s (0 B/s)
   authenticate 'focal.tar.gz' against 'focal.tar.gz.gpg'
   extracting 'focal.tar.gz'
   ```

3. **Checking Package Manager**:
   - The system checks the package manager and ensures it's ready.

   ```plaintext
   Reading cache
   Checking package manager
   ```

4. **SSH Upgrade Warning**:
   - If you're upgrading over SSH, the system issues a warning. Upgrading over SSH can be risky as it may be difficult to recover from a failure.
   - If you choose to continue, an additional SSH daemon will be started on port '1022' for reconnection if the connection is lost.

   ```plaintext
   Continue running under SSH?

   This session appears to be running under ssh. It is not recommended
   to perform a upgrade over ssh currently because in case of failure it
   is harder to recover.

   If you continue, an additional ssh daemon will be started at port
   '1022'.
   Do you want to continue?

   Continue [yN]
   ```

5. **User Confirmation**:
   - If you opt to proceed over SSH, you can press 'y' to continue.
   - If you prefer not to, you can press 'N' to cancel the operation.

#### Pre-Upgrade Summary

Before any changes are made, the command performs some checks and verifies if the system is ready for the upgrade. Once it determines readiness, it provides a summary of changes. If you accept the changes, the system begins the upgrade process by updating its packages:

```plaintext
Do you want to start the upgrade?  

5 installed packages are no longer supported by Canonical. You can  
still get support from the community.  

4 packages are going to be removed. 117 new packages are going to be  
installed. 424 packages are going to be upgraded.  

You have to download a total of 262 M. This download will take about  
33 minutes with a 1Mbit DSL connection and about 10 hours with a 56k  
modem.  
```

Downloading and upgrading may take several hours. Once the download is complete, the process cannot be canceled.

```plaintext
Continue [yN]  Details [d]
```

#### Configuration Changes

During the upgrade process, you may encounter messages requiring decisions regarding your configuration files. These messages appear when there are differences between the current configuration files (e.g., edited by the user) and the new package configuration files. Here's an example message:

```plaintext
Configuration file '/etc/ssh/ssh_config'
 ==> Modified (by you or by a script) since installation.
 ==> Package distributor has shipped an updated version.
   What would you like to do about it? Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : start a shell to examine the situation
 The default action is to keep your current version.
*** ssh_config (Y/I/N/O/D/Z) [default=N] ?
```

You'll need to review the differences between the files to decide what action to take. The default action is to keep your current version, but sometimes accepting the new version may be necessary, such as for files like `/boot/grub/menu.lst` to ensure proper booting with a new kernel.

#### Removing Packages

Once all packages are upgraded, you'll be prompted to remove any obsolete packages:

```plaintext
Remove obsolete packages?  
30 packages are going to be removed.
Continue [yN]  Details [d]
```

### 5. Restart the System

Finally, after completing the upgrade process, the system will prompt you to restart. The upgrade is not considered complete until the system is restarted:

```plaintext
System upgrade is complete.
Restart required

To finish the upgrade, a restart is required.
If you select 'y' the system will be restarted.
Continue [yN]
```

### 6. Remove Firewall Rule

Now that you've completed the upgrade to the latest version, you can remove the firewall rule for port 1022. The reason for this is to keep our system secure and ensure that unmonitored ports don't pose various security risks.

```bash
sudo ufw delete allow 1022/tcp
```

By following these steps, you can successfully upgrade your Ubuntu 18.04 LTS system to Ubuntu 22.04 LTS. Be cautious and seek assistance when needed to prevent and resolve any issues you may encounter during the upgrade process.

### References

- [Ubuntu Release](https://github.com/canonical/subiquity/releases)
- [How to upgrade](https://ubuntu.com/server/docs/how-to-upgrade-your-release)
- [Mirror List](http://tr.archive.ubuntu.com/ubuntu)
- [Upgrading from Ubuntu 18.04 LTS to 22.04 LTS](https://medium.com/@BabajideKale/upgrading-from-ubuntu-18-04-lts-to-22-04-lts-adf5f4a54ffa)
- [How to Upgrade from Ubuntu 22.04 LTS to Ubuntu 24.04 LTS](https://jumpcloud.com/blog/how-to-upgrade-ubuntu-22-04-to-ubuntu-24-04)
