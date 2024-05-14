# Ubuntu 18.04 LTS'den Ubuntu 22.04 LTS'ye Sürüm Yükseltme Adımları

**Not:** Ubuntu, ardışık sırayla bir LTS (Long Term Support) sürümünden diğerine yükseltmeyi destekler. Örneğin, Ubuntu 16.04 LTS kullanıcısı Ubuntu 18.04 LTS'ye yükseltebilir, ancak Ubuntu 20.04 LTS'ye doğrudan atlayamaz. Bunun için kullanıcı, önce Ubuntu 18.04 LTS'ye, ardından tekrar Ubuntu 20.04 LTS'ye yükseltilmelidir.

## Adımlar

### 1. Yedekleme

Her zaman olduğu gibi, sistemdeki önemli verileri ve yapılandırmaları yedekleyin. Sürüm yükseltmeleri bazen beklenmedik sorunlara neden olabilir.

`sudo rsync -a --progress /home/your_username /path_to_backup_location/home_backup`

`sudo rsync -a –progress /etc /path_to_backup_location/etc_backup`

### 2. Yükseltme Öncesi Kontrol Listesi

- **Sistemi Güncelleyin:** Mevcut sistemde en son güncellemelerin tümü yüklü olduğunda yükseltme işlemi en iyi şekilde çalışır. Ayrıca, en son çekirdeğin çalıştırıldığından emin olmak için tüm güncellemeler uygulandıktan sonra sistemi yeniden başlatın.

  ```bash
  sudo apt update
  sudo apt upgrade
  sudo reboot
  ```

- **Boş Disk Alanı Kontrolü:** Yükseltme için yeterli boş disk alanı olup olmadığını kontrol edin. Bir sistemin yükseltilmesi, muhtemelen yüzlerce yeni paketten oluşan yeni paketlerin indirilmesini içerecektir. Ek yazılımın yüklü olduğu sistemler bu nedenle birkaç gigabaytlık boş disk alanına ihtiyaç duyabilir.

- **`sudo apt dist-upgrade`:** Bu komut, sistemdeki mevcut paketleri yükseltir ve gerektiğinde yeni paketler yükler veya mevcut paketleri kaldırır. Paket bağımlılıklarını daha agresif bir şekilde yönetir, bu nedenle gerektiğinde paketlerin kaldırılmasına veya yeni paketlerin eklenmesine izin verir.

  ```bash
  sudo apt dist-upgrade
  ```

- **Üçüncü Taraf Yazılım Depoları ve PPA'lar:** Yükseltme sırasında üçüncü taraf yazılım depoları ve kişisel paket arşivleri (PPA'lar) devre dışı bırakılır. Ancak bu depolardan yüklenen hiçbir yazılım kaldırılmaz veya sürümü düşürülmez. Bu depolardan yüklenen yazılımlar, yükseltme sorunlarının en yaygın nedenidir.

- **Kullanılmayan Paketlerin Kaldırılması:** Sistemde artık kullanılmayan bağımlılıkları tespit edin ve bunları kaldırın. Bu, sistemde gereksiz dosyaların birikmesini önler ve disk alanınızı boşaltır.

  ```bash
  ls -l /etc/apt/sources.list.d/ # Depoları görüntülemek için bu komutu çalıştırabilirsiniz
  sudo apt autoremove –purge
  ```

- **Yüklü Yazılımları Belgeleyin:** Mevcut sistemde yüklü olan tüm paketlerin bir listesini oluşturun ve bu listeyi yükseltme sonrası kontrol için saklayın.

  ```bash
  dpkg --get-selections | grep -v deinstall | awk '{print $1}' > installed-software.txt
  ```

- **Paketleri Tekrardan Yükleme:** Bu şekilde kurulu olan tüm paketler hakkında bilgi sahibi olabiliriz ve gerektiğinde bunları daha sonra yeniden yükleyebiliriz.

    ```bash
    sudo dpkg –set-selections < installed-software.txt
    sudo apt-get dselect-upgrade
    ```

**Not:** Bu işlemi çalışma bittiken sonra yapmak daha sağlıklı olacaktır.

Tabii, eklemek istediğiniz bölümleri aşağıdaki gibi dökümanınıza ekleyebilirsiniz:

---

### 3. TCP Port 1022'yi Hazırlama

**Not:** Saldırı yüzeyinizi genişletmekten kaçınmak için mümkün olduğunca bir kale (bastion host) kullanmak güvenlik açısından en iyi uygulamadır.

SSH bağlantıları için varsayılan port 22'dir. Yükseltme sırasında SSH yapılandırması değiştirilmiş veya yanlış ayarlanmış olabilir ve varsayılan SSH hizmeti erişilemez hale gelebilir. Port 1022'nin ikincil bir SSH portu olarak ayarlanması, varsayılan port üzerinde oluşabilecek sorunları gidermek ve uzaktan erişiminizi sağlamak için önemlidir.

Yükseltme işlemi sırasında, SSH dahil çeşitli hizmetler ve yapılandırmalar yeniden başlatılabilir veya yeniden yüklenebilir. Bu işlemler sırasında bir şeyler ters giderse, ek bir porta sahip olmak, sunucuya uzaktan erişimi kaybetmemize engel olabilir.

İlk olarak, Ubuntu güvenlik duvarında bu belirli porta izin verelim:

```bash
sudo ufw allow 1022/tcp
```

Kuralı uygulamak için aşağıdaki komutu çalıştırın:

```bash
sudo ufw reload
```

Son olarak, portların düzgün bir şekilde listelendiğini kontrol edebiliriz:

```bash
sudo ufw status
```

### 4. Sistemi Yükseltin

**Do-release-upgrade Komutu:** Sunucu sürümü ve bulut görüntüleri üzerinde `do-release-upgrade` komutunu kullanarak sistemi yükseltmenizi öneririz. Bu komut, bazen sürümler arasında ihtiyaç duyulan sistem yapılandırması değişikliklerini işleyebilir.

#### `sudo do-release-upgrade` Komutu

1. **Komut Çalıştırma**:

   ```bash
   sudo do-release-upgrade
   ```

2. **Yükseltme Süreci**:
   - Komutu çalıştırdıktan sonra, sistem yeni bir Ubuntu sürümü için kontrol yapar.
   - Yeni sürüm bulunursa, yükseltme aracını indirir ve doğrular.

   ```plaintext
   root@ubuntu:~# sudo do-release-upgrade
   Checking for a new Ubuntu release
   Get:1 Upgrade tool signature [1,554 B]
   Get:2 Upgrade tool [1,338 kB]
   Fetched 1,340 kB in 0s (0 B/s)
   authenticate 'focal.tar.gz' against 'focal.tar.gz.gpg'
   extracting 'focal.tar.gz'
   ```

3. **Paket Yöneticisini Kontrol Etme**:
   - Sistem, paket yöneticisini kontrol eder ve hazır olup olmadığını doğrular.

   ```plaintext
   Reading cache
   Checking package manager
   ```

4. **SSH Üzerinden Yükseltme**:
   - SSH üzerinden yükseltme yapıyorsanız, sistem bir uyarı verir. SSH üzerinden yükseltme yapmak risklidir çünkü başarısızlık durumunda geri dönmek zor olabilir.
   - Devam etmek isterseniz, ek bir SSH daemon'u port 1022 üzerinde başlatılır. Bu, bağlantınız koparsa tekrar bağlanabilmeniz için bir güvenlik önlemidir.

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

5. **Kullanıcı Onayı**:
   - SSH üzerinden devam etmeyi seçerseniz, 'y' tuşuna basarak devam edebilirsiniz.
   - Devam etmek istemezseniz, 'N' tuşuna basarak işlemi iptal edebilirsiniz.

#### Ön Yükseltme Özeti

Değişiklikler yapılmadan önce, komut bazı kontroller yapar ve sistemin yükseltmeye hazır olup olmadığını doğrular. Yükseltmeye hazır olup olmadığını belirledikten sonra bir özet sunar. Değişiklikleri kabul ederseniz, sistemin paketlerini güncelleme işlemi başlar:

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

İndirme ve yükseltme işlemi birkaç saat sürebilir. İndirme tamamlandıktan sonra işlem iptal edilemez.

```plaintext
Continue [yN]  Details [d]
```

#### Yapılandırma Değişiklikleri

Yükseltme işlemi sırasında, yapılandırma dosyalarınızla ilgili kararlar almanız gereken mesajlarla karşılaşabilirsiniz. Bu mesajlar, mevcut yapılandırma dosyaları (örneğin, kullanıcı tarafından düzenlenmiş) ve yeni paket yapılandırma dosyaları arasında farklılıklar olduğunda ortaya çıkar. Aşağıda bir örnek mesaj bulunmaktadır:

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

Dosyalar arasındaki farkları inceleyerek ne yapacağınıza karar vermelisiniz. Varsayılan yanıt, mevcut dosyanın korunmasıdır. Ancak, bazı durumlarda (örneğin, `/boot/grub/menu.lst` gibi) yeni sürüm yapılandırmasını kabul etmek gerekebilir, çünkü yeni çekirdek ile sistemin doğru şekilde başlatılmasını sağlar.

#### Paketlerin Kaldırılması

Tüm paketler güncellendikten sonra, artık gereksiz olan paketleri kaldırmak için kullanıcıdan onay istenir:

```plaintext
Remove obsolete packages?  
30 packages are going to be removed.
Continue [yN]  Details [d]
```

### 5. Sistemi Yeniden Başlatma

Son olarak, yükseltme işlemi tamamlandığında sistemin yeniden başlatılması istenir. Sistem, yeniden başlatılana kadar tam olarak yükseltilmiş sayılmaz:

```plaintext
System upgrade is complete.
Restart required

To finish the upgrade, a restart is required.
If you select 'y' the system will be restarted.
Continue [yN]
```

### 6. Güvenlik Duvarı Kuralını Kaldırma

En son sürüme yükseltmeyi tamamladığımıza göre, 1022 numaralı port için güvenlik duvarı kuralını kaldırabiliriz. Bu işlemi yapmamızın ana nedeni, sistemimizi güvende tutmak ve denetlenmeyen portların çeşitli güvenlik açıklarına yol açabileceğinden emin olmaktır.

```bash
sudo ufw delete allow 1022/tcp
```

Bu adımları takip ederek Ubuntu 18.04 LTS sisteminizi başarılı bir şekilde Ubuntu 22.04 LTS'ye yükseltebilirsiniz. Yükseltme sırasında karşılaşabileceğiniz sorunları önlemek ve çözmek için dikkatli olun ve gerektiğinde yardım alın.

### Referanslar

- [Ubuntu Release](https://github.com/canonical/subiquity/releases)
- [How to upgrade](https://ubuntu.com/server/docs/how-to-upgrade-your-release)
- [Mirror List](http://tr.archive.ubuntu.com/ubuntu)
- [Upgrading from Ubuntu 18.04 LTS to 22.04 LTS](https://medium.com/@BabajideKale/upgrading-from-ubuntu-18-04-lts-to-22-04-lts-adf5f4a54ffa)
- [How to Upgrade from Ubuntu 22.04 LTS to Ubuntu 24.04 LTS](https://jumpcloud.com/blog/how-to-upgrade-ubuntu-22-04-to-ubuntu-24-04)
