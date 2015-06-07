# Kontena Jumpstarter

> Warning: Highly experimental stuff

Kontena Jumpstarter lets you create Kontena nodes on your computer, on cloud providers, and inside your own data center. It creates servers and installs Kontena on them.


## Usage

### Vagrant


#### Jumpstart Master Node

```
$ kontena-vagrant provision-master \
  --email=<admin email> \
  --size=512mb
```

#### Jumpstart Grid

```
$ kontena-vagrant provision-grid \
  --ssh-key=<path to ssh key> \
  --grid-token=<grid token> \
  --master-uri=<kontena master uri> \
  --grid-size=3 \
  --node-size=1gb
```



### DigitalOcean


#### Jumpstart Master Node

```
$ kontena-digitalocean provision-master \
  --email=<admin email> \
  --token=<do token> \
  --ssh-key=<path to ssh key> \
  --size=512mb \
  --region=ams3
```

#### Jumpstart Grid

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
