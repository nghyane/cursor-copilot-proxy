#!/usr/bin/env bash
# Docker services management

generate_config() {
    log "Generating configuration..."
    
    if [[ ! -f "generate.py" ]]; then
        error "generate.py not found"
        return 1
    fi
    
    python3 generate.py || {
        error "Configuration generation failed"
        return 1
    }
    
    success "Configuration generated"
}

start_services() {
    log "Starting services..."
    
    if ! docker compose up -d; then
        error "Failed to start services"
        return 1
    fi
    
    # Wait for services
    sleep 3
    success "Services started"
}

stop_services() {
    log "Stopping services..."
    docker compose down
    success "Services stopped"
}

restart_services() {
    log "Restarting services..."
    docker compose restart
    success "Services restarted"
}

show_status() {
    local ip
    ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")
    
    echo ""
    success "${ICON_ROCKET} Setup Complete!"
    echo ""
    info "🌐 Access Points:"
    echo "  • API Endpoint: http://$ip/"
    echo "  • Traefik Dashboard: http://$ip:8080"
    echo ""
    info "📊 Service Status:"
    docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    info "📋 Commands:"
    echo "  docker compose logs -f    # View logs"
    echo "  docker compose down       # Stop services"  
    echo "  docker compose restart   # Restart services"
    echo ""
    info "💡 To modify tokens: edit $TOKENS_FILE → python3 generate.py → docker compose up -d"
}

show_logs() {
    docker compose logs -f
}