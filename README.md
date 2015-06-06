# Kontena DigitalOcean Installer

Install Kontena to DigitalOcean without a fuzz.

## Usage

```
$ kontena-digitalocean provision-master \
  --email=<admin email> --token=<do token> --ssh-key-name=<do ssh key name>
  --size=512mb --region=ams3
```

```
$ kontena-digitalocean provision-grid --token=<do token> --ssh-key-name=<do ssh key name> \
  --grid-token=<grid token> --master-uri=<kontena master uri>
  --size=1gb --region=ams3
```
