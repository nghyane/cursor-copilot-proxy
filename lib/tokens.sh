#!/usr/bin/env bash
# GitHub token management

readonly TOKENS_FILE="tokens.json"

check_tokens() {
    [[ -f "$TOKENS_FILE" ]] && [[ -s "$TOKENS_FILE" ]]
}

validate_token() {
    local token="$1"
    [[ $token =~ ^(ghp_|gho_|ghu_|ghs_|ghr_|github_pat_) ]]
}

setup_tokens() {
    info "GitHub Token Setup"
    echo "Get tokens from: https://github.com/settings/tokens"
    echo "Required scopes: user:email, copilot"
    echo ""
    
    local tokens=()
    
    while true; do
        echo -n "Enter GitHub token (Enter to finish): "
        read -r token
        
        if [[ -z "$token" ]]; then
            [[ ${#tokens[@]} -gt 0 ]] && break
            warn "At least one token required"
            continue
        fi
        
        if validate_token "$token"; then
            tokens+=("$token")
            success "Token ${#tokens[@]} added (${token:0:8}...)"
        else
            error "Invalid token format"
        fi
    done
    
    # Generate tokens.json with proper formatting
    {
        echo "["
        for i in "${!tokens[@]}"; do
            local comma=""
            [[ $i -lt $((${#tokens[@]} - 1)) ]] && comma=","
            printf '  {"name": "copilot-api-%d", "token": "%s"}%s\n' \
                "$((i+1))" "${tokens[$i]}" "$comma"
        done
        echo "]"
    } > "$TOKENS_FILE"
    
    success "Created $TOKENS_FILE with ${#tokens[@]} token(s)"
}

list_tokens() {
    if ! check_tokens; then
        warn "No tokens configured"
        return 1
    fi
    
    info "Configured tokens:"
    python3 -c "
import json
with open('$TOKENS_FILE') as f:
    tokens = json.load(f)
    for i, token in enumerate(tokens, 1):
        print(f'  {i}. {token[\"name\"]} ({token[\"token\"][:8]}...)')
"
}