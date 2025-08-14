@echo off
setlocal

REM ===== 필수 설정 =====
set REPO_URL=https://github.com/harryk521/tetris2-pwa-full.git
set MSG=Deploy Tetris PWA

echo [CHECK] Git repo check...
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 goto NOT_REPO

echo [GIT] origin url sync...
git remote get-url origin >nul 2>&1
if errorlevel 1 goto ADD_REMOTE
goto SET_REMOTE

:ADD_REMOTE
git remote add origin %REPO_URL%
goto BRANCH_STEP

:SET_REMOTE
git remote set-url origin %REPO_URL%

:BRANCH_STEP
echo [GIT] set default branch to main
git branch -M main >nul 2>&1

echo [GIT] staging
git add -A

echo [GIT] committing (no error if nothing to commit)
git commit -m "%MSG%" 2>nul

echo [GIT] pushing to origin/main
git push -u origin main

echo.
echo [DONE] Push complete. GitHub Pages will serve the latest files shortly.
echo URL: https://harryk521.github.io/tetris2-pwa-full/
echo.
pause
goto END

:NOT_REPO
echo [ERR] Not a Git repo. Run this inside the cloned folder tetris2-pwa-full.
echo Tip: cd %%HOMEPATH%%\Desktop\tetris2-pwa-full
pause

:END
endlocal
