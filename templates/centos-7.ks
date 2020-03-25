network --bootproto=dhcp --hostname={{ hcloud_ks__server }}

### Use the Hetzner mirror for fast installations
url --url="{{ hcloud_ks__mirror }}/{{ hcloud_ks__version }}/os/x86_64"
repo --name="mirror-updates" --baseurl={{ hcloud_ks__mirror }}/{{ hcloud_ks__version }}/updates/x86_64

### Enable the firewall and allow only SSH
services --disabled=ip6tables,iptables,netfs,rawdevices --enabled=network,sshd
firewall --enable --ssh

### Install in text mode and reboot after installation
install
text
skipx
reboot

firstboot --disable

### Do not overwrite data on any data disk
ignoredisk --only-use={{ hcloud_ks__disk }}

### Set locale and timezone
keyboard --vckeymap=us
lang en_US.UTF-8
timezone Etc/UTC --isUtc --nontp

### Set a root password
auth --enableshadow --passalgo=sha512
rootpw --iscrypted {{ hcloud_ks__crypted_root_password }}

### Partition the disk
zerombr
clearpart --all --initlabel
bootloader --location=mbr --boot-drive={{ hcloud_ks__disk }}

### Use LVM
part /boot --fstype=xfs --size=500 --asprimary --fsoptions="defaults" --ondrive={{ hcloud_ks__disk }}
part pv.01 --size=1 --grow --ondrive={{ hcloud_ks__disk }}
volgroup vg_{{ hcloud_ks__server }}_root pv.01 --pesize=32768
logvol / --fstype=xfs --name=lv_root --vgname=vg_{{ hcloud_ks__server }}_root --size=4096 --fsoptions="defaults,relatime"
logvol /var --fstype=xfs --name=lv_var --vgname=vg_{{ hcloud_ks__server }}_root --size=4096 --fsoptions="defaults,relatime"
logvol swap --fstype=swap --name=lv_swap --vgname=vg_{{ hcloud_ks__server }}_root --size=1024 --fsoptions="defaults"

### Do not install packages that are not required
%packages --nobase
@core --nodefaults
libselinux-python
-*-firmware
-NetworkManager*
-alsa*
-audit
-cron*
-iprutils
-kexec-tools
-microcode_ctl
-plymouth*
-postfix
-rdma
-tuned
-wpa_supplicant
%end

%post
### Install the SSH key
mkdir -m0700 /root/.ssh/
cat <<EOF >/root/.ssh/authorized_keys
{% for key in hcloud_ks__ssh_keys %}
{{ key.key }}
{% endfor %}
EOF
chmod 0600 /root/.ssh/authorized_keys
restorecon -R /root/.ssh/

### Enable tmpfs
systemctl enable tmp.mount

%end
