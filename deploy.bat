@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== 사용자 설정(필요시 변경) =====
set "REPO_URL=https://github.com/harryk521/tetris2-pwa-full.git"

REM ===== 커밋 메시지 인자 처리 (공백/특수문자 안전) =====
set "MSG=%*"
if "%~1"=="" set "MSG=Deploy Tetris PWA"
REM 따옴표는 git -m 에서 문제되므로 제거
set "MSG=%MSG:"=%"

REM ===== Git 설치 확인 =====
where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git이 설치되어 있지 않습니다. https://git-scm.com/ 에서 설치 후 다시 시도하세요.
  pause
  exit /b 1
)

REM ===== Git 초기화(처음만) & 원격 연결 =====
if not exist .git (
  echo [INIT] Git 초기화...
  git init
  git branch -M main
)

REM origin 없으면 추가, 있으면 그대로 사용
git remote | findstr /i "^origin$" >nul 2>nul
if errorlevel 1 (
  echo [INIT] 원격(origin) 추가: %REPO_URL%
  git remote add origin %REPO_URL%
)

REM ===== service-worker.js 의 CACHE_NAME 자동 버전업 =====
if exist "service-worker.js" (
  for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%t"
  echo [CACHE] service-worker.js 의 CACHE_NAME -> tetris-%TS%

  powershell -NoProfile -Command ^
   "$p='service-worker.js';" ^
   "$c=Get-Content $p -Raw;" ^
   "$c=$c -replace 'const\s+CACHE_NAME\s*=\s*''[^'']*'';','const CACHE_NAME = ''tetris-%TS%'';';" ^
   "Set-Content -Path $p -Value $c -Encoding UTF8;"
) else (
  echo [WARN] service-worker.js 파일이 없어 캐시 버전업을 건너뜁니다.
)

REM ===== add / commit / push =====
echo [GIT] 변경 스테이징...
git add -A

echo [GIT] 커밋 시도...
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "%MSG%"
) else (
  echo [GIT] 커밋할 변경 사항이 없습니다.
)

echo [GIT] push origin main ...
git push -u origin main
if errorlevel 1 (
  echo.
  echo [HINT] push 인증 실패 시 GitHub 비밀번호 대신 **Personal Access Token**을 사용해야 합니다.
  echo       생성 경로: GitHub ^> Settings ^> Developer settings ^> Personal access tokens
  echo.
  pause
  exit /b 1
)

echo.
echo [DONE] 푸시 완료. GitHub Pages가 곧 최신 파일로 배포합니다.
echo URL: https://harryk521.github.io/tetris2-pwa-full/
echo.
pause

