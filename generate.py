#!/usr/bin/env python3
"""
Generate docker-compose.yaml and traefik/rr.yml using Jinja2 templates
for Traefik v3.4 load-balanced setup.
"""

import os
import json
from jinja2 import Environment, FileSystemLoader

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Load tokens
with open(os.path.join(BASE_DIR, "tokens.json")) as f:
    services = json.load(f)

# Prompt domains
default_domains = ["test.localhost", "cookora.local"]
domains_input = input(f"🌐 Enter domains (comma-separated) [default: {', '.join(default_domains)}]: ").strip()
domains = [d.strip() for d in (domains_input.split(",") if domains_input else default_domains)]

# Generate rule with Traefik v3 syntax
rule = " || ".join([f"Host(`{d}`)" for d in domains])

# Setup Jinja2 environment
env = Environment(loader=FileSystemLoader(os.path.join(BASE_DIR, "templates")))

# Render docker-compose.yaml
compose_tpl = env.get_template("docker-compose.yaml.j2")
with open(os.path.join(BASE_DIR, "docker-compose.yaml"), "w") as f:
    f.write(compose_tpl.render(services=services))

# Render traefik/rr.yml
rr_tpl = env.get_template("rr.yml.j2")
os.makedirs(os.path.join(BASE_DIR, "traefik"), exist_ok=True)
with open(os.path.join(BASE_DIR, "traefik/rr.yml"), "w") as f:
    f.write(rr_tpl.render(services=services, rule=rule))

print(f"✅ Generated docker-compose.yaml and traefik/rr.yml (HTTP only - SSL handled by Cloudflare)")
print(f"📋 Rule: {rule}")
print("💡 Note: HTTPS/SSL is handled by Cloudflare proxy")
