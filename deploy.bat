@echo off
setlocal enabledelayedexpansion

REM ====== 사용자 설정(필요시 변경) ======
set REPO_URL=https://github.com/harryk521/tetris2-pwa-full.git

REM 커밋 메시지 인자 처리
set MSG=%*
if "%MSG%"=="" set MSG=Deploy Tetris PWA

REM ====== 0) Git 설치 확인 ======
where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git이 설치되어 있지 않습니다. https://git-scm.com/ 에서 설치 후 다시 시도하세요.
  pause
  exit /b 1
)

REM ====== 1) Git 초기화(처음 한번) & 원격 연결 ======
if not exist .git (
  echo [INIT] Git 초기화 중...
  git init
  git branch -M main
  echo [INIT] 원격(origin) 추가: %REPO_URL%
  git remote add origin %REPO_URL%
)

REM ====== 2) service-worker.js 의 CACHE_NAME 자동 버전업 ======
if exist service-worker.js (
  for /f "tokens=1-3 delims=/- " %%a in ("%date%") do ( set TODAY=%%a%%b%%c )
  for /f "tokens=1-2 delims=:." %%h in ("%time%") do ( set NOW=%%h%%i )
  set TS=%TODAY%_%NOW%
  echo [CACHE] service-worker.js 의 CACHE_NAME 을 tetris-%TS% 로 변경합니다.

  powershell -NoProfile -Command ^
    "$p='service-worker.js';" ^
    "$c=Get-Content $p -Raw;" ^
    "$c=$c -replace \"const CACHE_NAME = '.*?';\",\"const CACHE_NAME = 'tetris-%TS%';\";" ^
    "Set-Content -Path $p -Value $c -Encoding UTF8;"
) else (
  echo [WARN] service-worker.js 파일이 없어 캐시 버전 업을 건너뜁니다.
)

REM ====== 3) 변경사항 스테이징 & 커밋 ======
echo [GIT] add/commit 진행...
git add -A

REM 커밋할 게 없으면 에러가 나므로, 먼저 변경 여부 확인
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "%MSG%"
) else (
  echo [GIT] 커밋할 변경 사항이 없습니다.
)

REM ====== 4) main 브랜치로 푸시 ======
echo [GIT] push origin main ...
git push -u origin main
if errorlevel 1 (
  echo.
  echo [TIP] 푸시 인증 시 GitHub 계정 비밀번호 대신 **Personal Access Token** 을 비밀번호 칸에 입력해야 합니다.
  echo      토큰 만들기: GitHub 프로필 ^> Settings ^> Developer settings ^> Personal access tokens
  echo.
  pause
  exit /b 1
)

echo.
echo [DONE] 푸시가 완료되었습니다. GitHub Pages가 곧 최신 파일로 배포합니다.
echo 배포 URL 예: https://harryk521.github.io/tetris2-pwa-full/
echo.
pause
