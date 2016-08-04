ssh:
  config_ssh: True
  user: root
  passwd: 123456
  ssh_hosts:
    pca-test:
      roles:
        pca
    oat-test:
      roles:
        oat-server
    vtpm:
      roles:
        oat-client
