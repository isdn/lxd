To build a custom LXD image, based on an Ubuntu Base image, run the `build.sh` script.
The Base image is fetched from `http://cdimage.ubuntu.com/ubuntu-base/`.

Cloud init scripts are supported.

The following user properties are accepted:

user.meta-data
user.network-config
user.user-data
user.vendor-data

For example, network settings:

```yaml
#cloud-config
version: 1
config:
  - type: physical
    name: eth0
    subnets:
      - type: static
        ipv4: true
        address: 10.98.176.107
        netmask: 255.255.255.0
        gateway: 10.98.176.1
        control: auto
  - type: nameserver
    address: 10.98.176.1
```

Then, init a new container:

```bash
lxc init ubuntu-base-v5 test-container --config=user.network-config="$(cat net-conf.yaml)"
```
