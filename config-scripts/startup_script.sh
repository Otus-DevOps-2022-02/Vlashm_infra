#!/bin/bash
USER_PUB_KEY=$(cat ~/.ssh/appuser.pub)

cat > metadata.yml << EOM
#cloud-config
timezone: Europe/Moscow

users:
  - name: appuser
    groups: sudo
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    ssh-authorized-keys:
    - $USER_PUB_KEY

apt:
  arches: [default]
  sources:
    source1:
      source: "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse"
      key: |
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v1.4.11 (GNU/Linux)

        mQINBFrXrqYBEACscLj2qgPpHBCQtgW1Yh29Ddgv6jssyWLAYmj0qngFLKoQMMbt
        SNBZylIKxfS+pUD9J5xfRZwfZOmtMIOFVWS9tcpeQXsiwC126tRyoFCIpoTmH7+R
        8/FfPrCYyXLP+ftEZfRV60wTwr5drR0S5pVIST3oaXXGkHkFC35U++udUG2Tl4Cs
        OPSCp1tsK6UOTjHFDH8PnasImJgD37QC8OOMIJS0jCtDZywJW6OCdpIRbuTWPK3P
        P48NLwGUJHixhVCmOgPPu9kDAfG3wLxiN85S2UbaaSXsdA4fF4SSwWNHTIYAg0yT
        xGepVyW4lkfcvng4jva24rQ9j1cm1b7bWeOkMH1aAcSyFzKCeNCNxbVOYVrcWNP4
        zrSUvsTKhwX8rPFMq9LkcKirDL9bRILvn/24VU6NdJfGbRjR6+Q7ooj7hYKLXtO5
        q0Q4nhjigpTWIoU6jdfbM9YqpKSELNnkDRAU+bRYSrNaFuizYgDZQvcVT6gbq26f
        JbgihoeJogEfim3kqRRJ3EUhE+EaVijl9iLDKkpurod26P2QSq9RKSuOCeauPjQv
        3BIiEMXco8O3v8W1y4TbnSQ3d28W9pN28IgAhmN2EU2sKqWPzNeG0V+L6mE5pA4o
        nD3z3JRpxAUFw08+9LnLRZ4D1u54OrHADsU8UpYZJCm1xw6T0e4dlxW6rQARAQAB
        tDdNb25nb0RCIDQuMiBSZWxlYXNlIFNpZ25pbmcgS2V5IDxwYWNrYWdpbmdAbW9u
        Z29kYi5jb20+iQI+BBMBAgAoBQJa166mAhsDBQkJZgGABgsJCAcDAgYVCAIJCgsE
        FgIDAQIeAQIXgAAKCRBLfFSaBY+LaxdXEACJMvkgr3Nt2xme9/6brGMbrEy6mQn7
        DZP98DXuS0tWvO5vkEO5IfRIvzG3zA0pATSBDVA0BvGnebQrGXZZ7Xfh0gz+zxlt
        TXv4eCyb6T4gRJuuQSFPTyDnZ3MbPESqj0UpIALmcLDJ01nqvbNPKxx5r08XQOtE
        i44Kcwc1Px5cPcYP9nmpDNLZjz3gkTm+zBygdE9beP02qXq7WcyghFmQZoLBW53e
        TqNPnMrrm5+6vgq+r/ttyiYTo7Zw8MrifN5okevzB0JhhSAW9g+4ZOp1QYbV8u8V
        pksJQDOIaBWIw8zosIQJTCVyd4hOyl8Ib2s2R0/grT51RgLYCNbUG6WTpKGgYBtr
        Mng10gozyDrnA3B+RiDx5uq+dNzuuMXWMit2nbcdanXdKNkaPmC6WVeU0rG5K1Wz
        jQMDvAInTszLcqH6zfEsjCoXj0z8UwcC4jahFDNMDBk3OhjMSL+fnvIhW84nKVHf
        AWL5jjSQdkrM/M8QRpRqls5apuIYHQwo6Oyd2Nk0n9T/GOMJ1jilxiPw9ihusf+k
        DfU0JI7T8fgxIv/wHNXUg7FOaaDJIfgGlCPUgtsNUDZZ9lFq+Zc5H8Wff3LNo7Se
        2xnzzoy2e+C3tsxAmVUTs+q0lyIzEK24lf71cp074KVV7rIYBELYtO2hAlJYjXJU
        bscTTjCKLf9leA==
        =UXPP
        -----END PGP PUBLIC KEY BLOCK-----
repo_update: true

packages:
  - ruby-full
  - ruby-bundler
  - build-essential
  - mongodb-org
  - git

runcmd:
  - sudo systemctl start mongod
  - sudo systemctl enable mongod
  - cd /home/appuser
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd /home/appuser/reddit
  - bundle install
  - puma -d
EOM

yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=./metadata.yml

  rm -f metadata.yml
