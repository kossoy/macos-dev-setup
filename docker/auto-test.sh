#!/bin/bash
# Fully automated test script - no user input required

echo "🤖 Running fully automated test..."

# Create automated input
cat > /tmp/auto-input.txt << 'EOF'
Test User
test@example.com
test@personal.com
TEST_WORK
TEST_PERSONAL
testuser
testuser
1
test-vpn
1
y
EOF

# Test bootstrap script with automated input
echo "Testing bootstrap script with automated input..."
timeout 120s ./bootstrap.sh < /tmp/auto-input.txt || {
    echo "❌ Bootstrap script failed or timed out"
    exit 1
}

echo "✅ Automated test completed successfully"
