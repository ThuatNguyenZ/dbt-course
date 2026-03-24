@echo off
REM DBT Course - Environment Setup Script (Windows)
REM This script sets up the complete development environment for the DBT course

echo 🚀 DBT Course - Environment Setup
echo ==================================

REM Check Python version
echo.
echo Checking Python version...
python --version
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.9+ from https://www.python.org/
    pause
    exit /b 1
)

REM Create virtual environment
echo.
echo Creating virtual environment...
if not exist "dbt-venv" (
    python -m venv dbt-venv
    echo ✓ Virtual environment created
) else (
    echo ✓ Virtual environment already exists
)

REM Activate virtual environment
echo.
echo Activating virtual environment...
call dbt-venv\Scripts\activate.bat
echo ✓ Environment activated

REM Upgrade pip
echo.
echo Upgrading pip...
python -m pip install --upgrade pip

REM Install DBT Core
echo.
echo Installing DBT Core with PostgreSQL adapter...
pip install dbt-postgresql
echo ✓ DBT Core installed

REM Install additional packages
echo.
echo Installing additional packages...
pip install dbt-utils pandas pyyaml
echo ✓ Additional packages installed

REM Create DBT project
echo.
echo Creating DBT project...
if not exist "dbt-shopee-tiktok" (
    dbt init dbt-shopee-tiktok
    echo ✓ DBT project created
) else (
    echo ✓ DBT project already exists
)

REM Show DBT version
echo.
echo DBT Version:
dbt --version

REM Create sample directory structure
echo.
echo Creating sample directory structure...
if not exist "dbt-shopee-tiktok\models\staging" mkdir dbt-shopee-tiktok\models\staging
if not exist "dbt-shopee-tiktok\models\intermediate" mkdir dbt-shopee-tiktok\models\intermediate
if not exist "dbt-shopee-tiktok\models\marts" mkdir dbt-shopee-tiktok\models\marts
if not exist "dbt-shopee-tiktok\seeds" mkdir dbt-shopee-tiktok\seeds
if not exist "dbt-shopee-tiktok\tests" mkdir dbt-shopee-tiktok\tests
if not exist "dbt-shopee-tiktok\macros" mkdir dbt-shopee-tiktok\macros
if not exist "dbt-shopee-tiktok\snapshots" mkdir dbt-shopee-tiktok\snapshots
echo ✓ Directory structure created

REM Create .gitignore
echo.
echo Creating .gitignore...
(
echo # DBT
echo dbt_packages/
echo target/
echo logs/
echo *.pyc
echo __pycache__/
echo.
echo # Profiles ^(contains credentials!^)
echo profiles.yml
echo.
echo # Environment
echo .env
echo .env.local
echo *.env
echo.
echo # OS
echo .DS_Store
echo Thumbs.db
) > dbt-shopee-tiktok\.gitignore
echo ✓ .gitignore created

REM Create requirements.txt
echo.
echo Creating requirements.txt...
(
echo dbt-postgresql^>=1.6.0
echo dbt-utils^>=1.0.0
echo pandas^>=2.0.0
echo pyyaml^>=6.0
) > requirements.txt
echo ✓ requirements.txt created

REM Final instructions
echo.
echo ======================================
echo ✓ Setup Complete!
echo ======================================
echo.
echo Next steps:
echo 1. Activate virtual environment:
echo    dbt-venv\Scripts\activate
echo.
echo 2. Configure your profiles.yml:
echo    C:\Users\%USERNAME%\.dbt\profiles.yml
echo.
echo 3. Test your connection:
echo    cd dbt-shopee-tiktok
echo    dbt debug
echo.
echo 4. Start with Session 1:
echo    Open slides\session-01.html in your browser
echo.
echo For support, contact: [instructor@email.com]
echo.
pause
