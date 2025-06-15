#!/usr/bin/env bash
# Token management functions

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

validate_token() {
    local token="$1"
    if [[ $token =~ ^(ghp_|gho_|ghu_|ghs_|ghr_|github_pat_) ]]; then
        return 0
    else
        return 1
    fi
}

setup_tokens() {
    info "GitHub Token Setup"
    echo "Get your tokens from: https://github.com/settings/tokens"
    echo "Required scopes: user:email, copilot"
    echo ""
    
    local tokens=()
    
    while true; do
        echo -n "Enter GitHub token (or press Enter to finish): "
        read -r token
        
        # If empty and we have tokens, break
        if [[ -z "$token" ]] && [[ ${#tokens[@]} -gt 0 ]]; then
            break
        fi
        
        # If empty and no tokens, continue
        if [[ -z "$token" ]]; then
            warn "Please enter at least one token"
            continue
        fi
        
        # Validate token format
        if validate_token "$token"; then
            tokens+=("$token")
            success "Token ${#tokens[@]} added (${token:0:8}...)"
        else
            error "Invalid token format (should start with ghp_, gho_, etc.)"
        fi
    done
    
    # Generate tokens.json
    generate_tokens_json "${tokens[@]}"
    success "Created tokens.json with ${#tokens[@]} token(s)"
}

generate_tokens_json() {
    local tokens=("$@")
    {
        echo "["
        for i in "${!tokens[@]}"; do
            local comma=""
            [[ $i -lt $((${#tokens[@]} - 1)) ]] && comma=","
            echo "  {\"name\": \"copilot-api-$((i+1))\", \"token\": \"${tokens[$i]}\"}$comma"
        done
        echo "]"
    } > tokens.json
}

check_tokens() {
    if [[ ! -f "tokens.json" ]] || [[ ! -s "tokens.json" ]]; then
        return 1
    else
        return 0
    fi
}