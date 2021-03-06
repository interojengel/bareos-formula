# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set tm_config = bareos.traymonitor.config if bareos.traymonitor.config is defined else {} %}
{% set require_password = ['director'] %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

install_traymon_package:
  pkg.installed:
    - name: {{ bareos.traymonitor.pkg }}
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if tm_config != {} %}
bareos_traymon_cfg_file:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.traymonitor.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ tm_config|json() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: install_traymon_package
{% endif %}
