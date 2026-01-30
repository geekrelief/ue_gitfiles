:: --- Unreal project git lfs setup script ---
@echo off
setlocal enabledelayedexpansion

:: --- USAGE INSTRUCTIONS ---
if "%~1"=="" goto :usage
if "%~2"=="" goto :usage

set "FolderName=%~1"
set "AzureRepoURL=%~2"
set "UETOOLS_DIR=%~dp0"

:: --- COLOR DEFINITIONS ---
:: We create a literal Escape character (ASCII 27)
for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set ESC=%%b

:: Define the Rainbow
set "RED=!ESC![91m"
set "ORANGE=!ESC![38;2;255;140;0m"
set "YELLOW=!ESC![93m"
set "GREEN=!ESC![92m"
set "CYAN=!ESC![96m"
set "BLUE=!ESC![94m"
set "INDIGO=!ESC![38;5;63m"
set "VIOLET=!ESC![95m"
set "RESET=!ESC![0m"

:: Check if the directory does not exist
if not exist "%FolderName%\" (
    echo !VIOLET! [ERROR] Specified folder for local repo doesn't exist:!RESET!
    echo !YELLOW! %FolderName%!RESET!
    echo.
    echo Please choose another folder and try again.
    pause
    exit /b 1
)

git ls-remote "%AzureRepoURL%" -q >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo !VIOLET!"Repository %AzureRepoURL% not found or access denied."!RESET!
    exit /b 1
)

echo !CYAN!Azure repo found at %AzureRepoURL% continuing setup...!RESET!

cd %FolderName%

echo !CYAN!Checking Git repository and setting up Git LFS...!RESET!
if not exist "%FolderName%\.git" (
    echo !CYAN!Creating new Git repository...!RESET!
    git init
) else (
    echo !YELLOW!Found git repository already exists in %FolderName% !RESET!
)
copy %UETOOLS_DIR%/.gitignore %FolderName%
copy %UETOOLS_DIR%/.gitattributes %FolderName%
copy %UETOOLS_DIR%/UnlockGitLfsLocks.ps1 %FolderName%
copy %UETOOLS_DIR%/reference-transaction %FolderName%/.git/hooks/

git lfs install

echo !CYAN!Adding files to Git LFS tracking...!RESET!
git add .
git commit -m "Setup repo for Git LFS"

:: to fix a bug with Azure and HTTP/2
git config http.version HTTP/1.1

git remote add origin "%AzureRepoURL%"
git push -u origin main
:: Enable Git LFS lock verification
echo !CYAN!Enabling Git LFS lock verification...!RESET!
git config lfs.%AzureRepositoryURL%.git/info/lfs.locksverify true

echo !GREEN!Git LFS setup complete and initial commit pushed to %AzureRepoURL%!RESET!

echo !YELLOW!
echo Updating Config/DefaultEditorPerProjectUserSettings.ini
(
echo.
echo.
echo ; Git lfs settings
echo [/Script/UnrealEd.EditorLoadingSavingSettings]
echo bSCCAutoAddNewFiles=False
echo bAutomaticallyCheckoutOnAssetModification=True
echo bPromptForCheckoutOnAssetModification=False
echo bAutoloadCheckedOutPackages=True
echo.
) >> ".\Config\DefaultEditorPerProjectUserSettings.ini"

echo Updating Config/DefaultEngine.ini
(
echo.
echo.
echo ; Git lfs settings
echo [SystemSettingsEditor]
echo r.Editor.SkipSourceControlCheckForEditablePackages=1
echo.
) >> ".\Config\DefaultEngine.ini"

echo !GREEN!
echo Configuration files updated successfully. 
echo Git LFS setup complete.
echo !RESET!
exit /b 0

:usage
echo ====================================================
echo ERROR: Missing Parameters
echo ====================================================
echo Usage: %~nx0 [ProjectDirectory] [AzureRepositoryURL]
echo.
echo Example:
echo   %~nx0 D:\MyEngine https://geekrelief@dev.azure.com/geekrelief/MyProject/_git/MyProject
echo ====================================================
exit /b
