#!/bin/bash

# DBT Course - Environment Setup Script
# This script sets up the complete development environment for the DBT course

set -e  # Exit on error

echo "🚀 DBT Course - Environment Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python version
echo -e "\n${YELLOW}Checking Python version...${NC}"
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version: $python_version"

# Create virtual environment
echo -e "\n${YELLOW}Creating virtual environment...${NC}"
if [ ! -d "dbt-venv" ]; then
    python3 -m venv dbt-venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "\n${YELLOW}Activating virtual environment...${NC}"
source dbt-venv/bin/activate
echo -e "${GREEN}✓ Environment activated${NC}"

# Upgrade pip
echo -e "\n${YELLOW}Upgrading pip...${NC}"
pip install --upgrade pip

# Install DBT Core
echo -e "\n${YELLOW}Installing DBT Core with PostgreSQL adapter...${NC}"
pip install dbt-postgresql
echo -e "${GREEN}✓ DBT Core installed${NC}"

# Install additional packages
echo -e "\n${YELLOW}Installing additional packages...${NC}"
pip install dbt-utils pandas pyyaml
echo -e "${GREEN}✓ Additional packages installed${NC}"

# Create DBT project
echo -e "\n${YELLOW}Creating DBT project...${NC}"
if [ ! -d "dbt-shopee-tiktok" ]; then
    dbt init dbt-shopee-tiktok
    echo -e "${GREEN}✓ DBT project created${NC}"
else
    echo -e "${GREEN}✓ DBT project already exists${NC}"
fi

# Show DBT version
echo -e "\n${YELLOW}DBT Version:${NC}"
dbt --version

# Create sample directory structure
echo -e "\n${YELLOW}Creating sample directory structure...${NC}"
mkdir -p dbt-shopee-tiktok/{models/{staging,intermediate,marts},seeds,tests,macros,snapshots}
echo -e "${GREEN}✓ Directory structure created${NC}"

# Create .gitignore
echo -e "\n${YELLOW}Creating .gitignore...${NC}"
cat > dbt-shopee-tiktok/.gitignore << EOF
# DBT
dbt_packages/
target/
logs/
*.pyc
__pycache__/

# Profiles (contains credentials!)
profiles.yml

# Environment
.env
.env.local
*.env

# OS
.DS_Store
Thumbs.db
EOF
echo -e "${GREEN}✓ .gitignore created${NC}"

# Create requirements.txt
echo -e "\n${YELLOW}Creating requirements.txt...${NC}"
cat > requirements.txt << EOF
dbt-postgresql>=1.6.0
dbt-utils>=1.0.0
pandas>=2.0.0
pyyaml>=6.0
EOF
echo -e "${GREEN}✓ requirements.txt created${NC}"

# Final instructions
echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}======================================${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Activate virtual environment:"
echo "   source dbt-venv/bin/activate"
echo ""
echo "2. Configure your profiles.yml:"
echo "   ~/.dbt/profiles.yml"
echo ""
echo "3. Test your connection:"
echo "   cd dbt-shopee-tiktok"
echo "   dbt debug"
echo ""
echo "4. Start with Session 1:"
echo "   Open slides/session-01.html in your browser"
echo ""

# Platform-specific instructions
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 On Mac: open slides/session-01.html"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "📱 On Linux: xdg-open slides/session-01.html"
fi

echo ""
echo -e "${YELLOW}For support, contact: [instructor@email.com]${NC}"
