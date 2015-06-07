# Kontena Machine

> Warning: Highly experimental stuff

Kontena Machine lets you create Kontena nodes on your computer, on cloud providers, and inside your own data center. It creates servers and installs Kontena on them.


## Usage

### Vagrant


#### Provision Master Node

```
$ kontena-vagrant provision-master \
  --email=<admin email> \
  --size=512mb
```

#### Provision Grid

```
$ kontena-vagrant provision-grid \
  --ssh-key=<path to ssh key> \
  --grid-token=<grid token> \
  --master-uri=<kontena master uri> \
  --grid-size=3 \
  --node-size=1gb
```



### DigitalOcean


#### Provision Master Node

```
$ kontena-digitalocean provision-master \
  --email=<admin email> \
  --token=<do token> \
  --ssh-key=<path to ssh key> \
  --size=512mb \
  --region=ams3
```

#### Provision Grid

```
$ kontena-digitalocean provision-grid \
  --token=<do token> \
  --ssh-key=<path to ssh key> \
  --grid-token=<grid token> \
  --master-uri=<kontena master uri> \
  --grid-size=3 \
  --node-size=1gb \
  --region=ams3
```
