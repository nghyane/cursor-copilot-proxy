#!/usr/bin/env python3
"""Generate docker-compose.yaml for Traefik load balancer"""
import os, json
from jinja2 import Environment, FileSystemLoader

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(BASE_DIR, "tokens.json")) as f:
    services = json.load(f)

env = Environment(loader=FileSystemLoader(os.path.join(BASE_DIR, "templates")))
compose_tpl = env.get_template("docker-compose.yaml.j2")
with open(os.path.join(BASE_DIR, "docker-compose.yaml"), "w") as f:
    f.write(compose_tpl.render(services=services))

print("✅ Generated docker-compose.yaml with Traefik labels")
