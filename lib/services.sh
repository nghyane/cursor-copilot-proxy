#!/usr/bin/env bash
# Service management functions

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

generate_config() {
    log "Generating configuration..."
    if [[ -f "generate.py" ]]; then
        python3 generate.py
    else
        error "generate.py not found!"
        return 1
    fi
}

start_services() {
    log "Starting services..."
    docker compose up -d
    
    # Wait for services to start
    sleep 3
    success "Services started!"
}

stop_services() {
    log "Stopping services..."
    docker compose down
    success "Services stopped!"
}

restart_services() {
    log "Restarting services..."
    docker compose restart
    success "Services restarted!"
}

show_status() {
    local ip
    ip=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
    
    echo ""
    success "🎉 Setup Complete!"
    echo ""
    info "🌐 Access Points:"
    echo "  • API Endpoint: http://$ip/"
    echo "  • Traefik Dashboard: http://$ip:8080"
    echo ""
    info "📊 Service Status:"
    docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker compose ps
    echo ""
    info "📋 Useful Commands:"
    echo "  docker compose logs -f    # View logs"
    echo "  docker compose down       # Stop services"  
    echo "  docker compose restart   # Restart services"
    echo ""
    info "💡 To modify tokens: edit tokens.json → python3 generate.py → docker compose up -d"
}

show_logs() {
    docker compose logs -f "$@"
}