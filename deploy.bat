@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== User config =====
set "REPO_URL=https://github.com/harryk521/tetris2-pwa-full.git"

REM ===== Commit message (handles spaces) =====
set "MSG=%*"
if "%~1"=="" set "MSG=Deploy Tetris PWA"
REM remove double-quotes from message to avoid git -m issues
set "MSG=%MSG:"=%"

REM ===== Check Git =====
where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git is not installed. Install from https://git-scm.com/ and retry.
  pause
  exit /b 1
)

REM ===== Init repo once =====
if not exist .git (
  echo [INIT] Initializing git repo...
  git init
  git branch -M main
)

REM Ensure origin remote exists
git remote | findstr /i "^origin$" >nul 2>nul
if errorlevel 1 (
  echo [INIT] Adding remote origin: %REPO_URL%
  git remote add origin %REPO_URL%
)

REM ===== Bump service worker cache name =====
if exist "service-worker.js" (
  for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%t"
  echo [CACHE] Update service-worker.js -> CACHE_NAME tetris-%TS%

  powershell -NoProfile -Command ^
    "$p='service-worker.js';" ^
    "$c=Get-Content $p -Raw;" ^
    "$c=$c -replace 'const\s+CACHE_NAME\s*=\s*''[^'']*'';','const CACHE_NAME = ''tetris-%TS%'';';" ^
    "$c=$c -replace 'const\s+CACHE_NAME\s*=\s*\"[^\"]*\";','const CACHE_NAME = \"tetris-%TS%\";';" ^
    "Set-Content -Path $p -Value $c -Encoding UTF8;"
) else (
  echo [WARN] service-worker.js not found. Skipping cache bump.
)

REM ===== Add / Commit / Push =====
echo [GIT] Staging changes...
git add -A

echo [GIT] Committing...
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "%MSG%"
) else (
  echo [GIT] No changes to commit.
)

echo [GIT] Pushing to origin main...
git push -u origin main
if errorlevel 1 (
  echo.
  echo [HINT] If authentication fails, use a GitHub Personal Access Token as the password.
  echo       Create one: GitHub > Settings > Developer settings > Personal access tokens.
  echo.
  pause
  exit /b 1
)

echo.
echo [DONE] Push complete. GitHub Pages will serve the latest files shortly.
echo URL: https://harryk521.github.io/tetris2-pwa-full/
echo.
pause
