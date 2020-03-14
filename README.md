# ansible-role-hcloud-kickstart

This repository contains a role to Kickstart CentOS (or even Red Hat Enterprise Linux) servers on [Hetzner Cloud](https://www.hetzner.de/cloud).

An example playbook is available in [examples/](examples/)

## Role Variables

### Required

To access the server, at least one SSH public key needs to be allowed:

```yml
hcloud_ks__ssh_keys:
- name: <my-key-name>
  key: "<my-public-key"
```

Note that the key with the given name needs to be available in the Hetzner Cloud project.

When not using a custom Kickstart, the server needs a root password as well:

```yml
hcloud_ks__crypted_root_password: ""
```

The Fedora kickstart instructions recommend creating the password by running:

```bash
$ python -c 'import crypt; print(crypt.crypt("My Password", "$6$My Salt"))'
```

Replace `My Password` by the chosen password and `My Salt` by a random salt.

### Optional

Access to Hetzner Cloud requires an API token.
This defaults to getting the token from the `HCLOUD_TOKEN` environment variable.

```yml
hcloud_ks__token: "{{ lookup('env', 'HCLOUD_TOKEN') }}"
```

The server name to kickstart defaults to `inventory_hostname_short`.

```yml
hcloud_ks__server: "{{ inventory_hostname_short }}"
```

The CentOS mirror to use defaults to the very fast Hetzner mirror:

```yml
hcloud_ks__mirror: "http://mirror.hetzner.de/centos"
```

The kickstart file that will be used defaults to the included CentOS 7 template:

```yml
hcloud_ks__version: "7"
hcloud_ks__kickstart: "centos-{{ hcloud_ks__version }}.ks"
```

Should the server have a drive that is not SATA, the drive used to install the system on can be configured:

```yml
hcloud_ks__disk: "sda"
```
