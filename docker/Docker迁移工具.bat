@echo off
chcp 65001 >nul
title Docker容器迁移工具
cls
echo =============================================
echo          Docker容器迁移工具
echo          正在启动PowerShell核心脚本...
echo =============================================
echo.

:: 临时提升PowerShell执行权限（无弹窗）
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force 2>&1 | Out-Null"

:: 调用PS1核心脚本（同目录）
powershell -ExecutionPolicy Bypass -File "%~dp0Docker-Migrate.ps1"

:: 执行完成后暂停
echo.
echo 脚本执行完成，按任意键退出...
pause >nul