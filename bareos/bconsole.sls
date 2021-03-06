# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set bc_config = bareos.bconsole.config if bareos.bconsole.config is defined else {} %}
{% set require_password = ['director'] %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

install_bconsole_package:
  pkg.installed:
    - name: {{ bareos.bconsole.pkg }}
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if bc_config != {} %}
bareos_bconsole_cfg_file:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.bconsole.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ bc_config|json() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: install_bconsole_package
{% endif %}
