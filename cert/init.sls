# This is the main state file for deploying certificates

{% from "cert/map.jinja" import map with context %}

# Install required packages
cert_packages:
  pkg.installed:
    - pkgs:
{% for pkg in map.pkgs %}
      - {{ pkg }}
{% endfor %}

# Deploy certificates
# Place all files in a files_roots/cert, e.g. /srv/salt/files/cert/

{% set run_ca_update = False  %}

{% for name, data in salt['pillar.get']('cert:certlist', {}).items() %}

  {% set key = data.get('key', False) %}
  {% set cert_user = data.get('cert_user', map.cert_user) %}
  {% set key_user = data.get('key_user', map.key_user) %}
  {% set cert_group = data.get('cert_group', map.cert_group) %}
  {% set key_group = data.get('key_group', map.key_group) %}
  {% set cert_mode = data.get('cert_mode', map.cert_mode) %}
  {% set key_mode = data.get('key_mode', map.key_mode) %}
  {% set cert_dir = data.get('cert_dir', map.cert_dir) %}
  {% set key_dir = data.get('key_dir', map.key_dir) %}
  {% set local_key_dir = data.get('local_cert_dir', 'cert') %}
  {% set is_ca = data.get('is_ca', False) %}

  {% if is_ca %}
    {% set run_ca_update = True %}
  {% endif %}

{{ cert_dir }}/{{ name }}:
  file.managed:
    - source: salt://{{ local_key_dir }}/{{ name }}
    - user: {{ cert_user }}  
    - group: {{ cert_group }}  
    - mode: {{ cert_mode }}  

  {% if key %}
{{ key_dir }}/{{ name }}.key:
  file.managed:
    - contents: |
{{ key|indent(8, True) }}
    - user: {{ key_user }}  
    - group: {{ key_group }}  
    - mode: {{ key_mode }}  
  {% endif %}

{% endfor %}

{% if run_ca_update %}
cert_ensure_update_update-ca-certificates:
  cmd.run:
    - name: update-ca-certificates
{% endif %}
