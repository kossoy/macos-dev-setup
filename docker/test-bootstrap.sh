#!/bin/bash
# Test script for bootstrap.sh in Docker environment

echo "🧪 Testing bootstrap script in Docker..."

# Create test input file
cat > /tmp/test-input.txt << EOF
John Doe
john.doe@company.com
john@personal.com
COMPANY_ORG
PERSONAL_ORG
john-doe
johndoe
3
portal
1
y
EOF

# Run bootstrap script with test input
echo "Running bootstrap script with test data..."
timeout 60s ./bootstrap.sh < /tmp/test-input.txt || {
    echo "❌ Bootstrap script failed or timed out"
    exit 1
}

echo "✅ Bootstrap script test completed"
