{% import 'conf/global.jinja' as conf with context  -%}

{% set host = salt['config.get']('host') %}
{% set role = salt['pillar.get']('ssh:ssh_hosts:' + host + ':roles') -%}

ssh_no_passwd:
  cmd.run:
    - name: |
       {% for h in conf.hosts %}
       bash {{conf.home}}/ssh_copy.sh {{conf.user}} {{conf.passwd}} {{h}}
       {% endfor %}
    - user: {{conf.user}}
    - cwd: {{conf.home}}
