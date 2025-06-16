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
print("🌐 Domain options:")
print("1. Enter specific domains (comma-separated)")
print("2. Use catch-all (accepts any domain) - recommended for Cloudflare")
print("3. Use default test domains")

choice = input("Choose option [1/2/3] (default: 3): ").strip()

if choice == "1":
    domains_input = input("Enter domains (comma-separated): ").strip()
    domains = [d.strip() for d in domains_input.split(",") if d.strip()]
    rule = " || ".join([f"Host(`{d}`)" for d in domains])
elif choice == "2":
    rule = "PathPrefix(`/`)"
    domains = ["any domain (catch-all)"]
else:
    domains = default_domains
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

print(f"✅ Generated docker-compose.yaml and traefik/rr.yml")
print(f"📋 Rule: {rule}")
print(f"🌐 Domains: {', '.join(domains)}")
print("💡 Note: HTTPS/SSL should be handled by Cloudflare proxy")
