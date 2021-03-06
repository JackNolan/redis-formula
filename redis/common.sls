{% set redis = pillar.get('redis', {}) -%}
{% set install_from = redis.get('install_from', 'source') -%}

{% if install_from == 'source' %}
{% set version = redis.get('version', 'stable') -%}
{% set checksum = redis.get('checksum', 'sha1=12755897666792eb9e1a0b7e4589eb1cb8e229d0') -%}
{% set root = redis.get('root', '/usr/local') -%}

redis-dependencies:
  pkg.installed:
    - names:
        - build-essential
        - python-dev
        - libxml2-dev

## Get redis
get-redis:
  file.managed:
    - name: {{ root }}/redis-{{ version }}.tar.gz
    - source: http://download.redis.io/releases/redis-{{ version }}.tar.gz
    - source_hash: {{ checksum }}
    - require:
      - pkg: redis-dependencies
  cmd.wait:
    - cwd: {{ root }}
    - names:
      - tar -zxvf {{ root }}/redis-{{ version }}.tar.gz -C {{ root }}
    - watch:
      - file: get-redis

make-redis:
  cmd.wait:
    - cwd: {{ root }}/redis-{{ version }}
    - names:
      - make
      - make install
    - watch:
      - cmd: get-redis

{% elif install_from == 'package' %}
{% set version = redis.get('version', None) -%}

install-redis:
  pkg.installed:
    - name: redis-server
    {% if version %}
    - version: {{ version }}
    {% endif %}

{% endif -%}
