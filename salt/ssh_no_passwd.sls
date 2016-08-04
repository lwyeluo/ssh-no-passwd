{% import 'conf/global.jinja' as conf with context  -%}

{% set host = salt['config.get']('host') %}
{% set role = salt['pillar.get']('ssh:ssh_hosts:' + host + ':roles') -%}

{# for /etc/hosts #}
/etc/hosts:
  file.managed:
    - source: salt://files/hosts
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: sed -i 's/^\(127.0.1.1\).*$/\1\t{{host}}/g' /etc/hosts

{% if conf.config_ssh %}
ssh:
  pkg:
    - name: ssh
    - installed
  service:
    - name: ssh
    - running
    - reload: True
    - watch:
      - file: /etc/ssh/sshd_config

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://files/sshd_config
    - user: root
    - group: root
    - mode: 644

ssh_config:
  cmd.run:
    - name: ssh-keygen -t rsa -P "" -f {{conf.home}}/.ssh/id_rsa
    - cwd: {{conf.home}}
    - user: {{conf.user}}
    - unless: test -f {{conf.home}}/.ssh/id_rsa
{% endif %}

user_no_passwd:
  cmd.run:
    - name: echo "{{conf.user}} ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/{{conf.user}}
    - unless: test -f /etc/sudoers.d/{{conf.user}}

{# for {{conf.home}}/ssh_copy.sh #}
{{conf.home}}/ssh_copy.sh:
  file.managed:
    - source: salt://files/scripts/ssh_copy.sh
    - user: {{conf.user}}
    - mode: 755

expect:
  pkg.installed:
    - name: expect

ssh_no_passwd:
  cmd.run:
    - name: |
       {% for h in conf.hosts %}
       ssh-keygen -R {{h}}
       bash {{conf.home}}/ssh_copy.sh {{conf.user}} {{conf.passwd}} {{h}}
       {% endfor %}
    - user: {{conf.user}}
    - cwd: {{conf.home}}
