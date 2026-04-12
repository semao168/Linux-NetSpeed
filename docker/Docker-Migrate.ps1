<#
Docker容器迁移工具（Windows版）- 强化文件名含容器名
核心优化：导出包名明确包含容器名，新增容器名标识文件
#>
# 强制统一编码（解决乱码）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "SilentlyContinue"

# 检查Docker运行状态
function Test-DockerRunning {
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker未启动，请先打开Docker Desktop" -ForegroundColor Red
        Read-Host "按回车退出"
        exit 1
    }
}

# 精准获取容器列表（仅Name/ID/Status）
function Get-ContainerInfo {
    $rawContainers = docker ps -a --format "{{.Names}}||{{.ID}}||{{.Status}}"
    $containerList = @()
    $index = 1

    foreach ($line in $rawContainers) {
        $bytes = [System.Text.Encoding]::Default.GetBytes($line)
        $decodedLine = [System.Text.Encoding]::UTF8.GetString($bytes)
        
        $parts = $decodedLine -split '\|\|'
        if ($parts.Count -eq 3) {
            $containerObj = [PSCustomObject]@{
                Index  = $index          
                Name   = $parts[0].Trim()
                ID     = $parts[1].Trim()
                Status = $parts[2].Trim()
            }
            $containerList += $containerObj
            $index++
        }
    }
    return $containerList
}

# 解析原容器配置（端口/挂载/环境变量）
function Get-OriginalConfig($configPath, $cname) {
    if (-not (Test-Path $configPath)) {
        return $null
    }
    # 读取config.json并解析关键配置
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $originalConfig = [PSCustomObject]@{
        Image      = $config.Config.Image
        Ports      = @()
        Volumes    = @()
        Env        = $config.Config.Env
        Restart    = $config.HostConfig.RestartPolicy.Name
    }
    # 解析端口映射（如 8080/tcp → 主机端口:容器端口）
    if ($config.HostConfig.PortBindings) {
        foreach ($port in $config.HostConfig.PortBindings.PSObject.Properties) {
            $containerPort = $port.Name -replace "/tcp", ""
            $hostPort = $port.Value.HostPort
            $originalConfig.Ports += @{HostPort = $hostPort; ContainerPort = $containerPort}
        }
    }
    # 解析挂载卷（盘符/目录映射）
    if ($config.HostConfig.Binds) {
        foreach ($bind in $config.HostConfig.Binds) {
            $parts = $bind -split ":"
            if ($parts.Count -eq 2) {
                $originalConfig.Volumes += @{HostPath = $parts[0]; ContainerPath = $parts[1]}
            }
        }
    }
    return $originalConfig
}

# 一键恢复原配置启动容器
function Start-ContainerWithOriginalConfig($originalConfig, $cname) {
    Clear-Host
    Write-Host "🔧 一键恢复[$cname]容器配置" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "原容器名称：$cname"
    Write-Host "镜像：$originalConfig.Image"
    Write-Host "重启策略：$originalConfig.Restart"
    Write-Host "端口映射："
    foreach ($port in $originalConfig.Ports) {
        Write-Host "  主机端口$($port.HostPort) → 容器端口$($port.ContainerPort)"
    }
    Write-Host "挂载卷："
    foreach ($vol in $originalConfig.Volumes) {
        Write-Host "  主机路径$($vol.HostPath) → 容器路径$($vol.ContainerPath)"
    }
    Write-Host "=============================================" -ForegroundColor Cyan

    $confirm = Read-Host "是否确认按原配置启动[$cname]容器？(Y/N)"
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        # 拼接启动命令
        $runCmd = "docker run -d --name $cname --restart=$($originalConfig.Restart)"
        # 添加端口映射
        foreach ($port in $originalConfig.Ports) {
            $runCmd += " -p $($port.HostPort):$($port.ContainerPort)"
        }
        # 添加挂载卷
        foreach ($vol in $originalConfig.Volumes) {
            # 确保主机路径存在
            if (-not (Test-Path $vol.HostPath)) {
                New-Item -ItemType Directory -Path $vol.HostPath -Force | Out-Null
            }
            $runCmd += " -v $($vol.HostPath):$($vol.ContainerPath)"
        }
        # 添加环境变量
        foreach ($env in $originalConfig.Env) {
            $runCmd += " -e ""$env"""
        }
        # 追加镜像名
        $runCmd += " $($originalConfig.Image)"

        # 执行启动命令
        Write-Host "`n🔹 执行启动命令：$runCmd" -ForegroundColor Yellow
        Invoke-Expression $runCmd
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ [$cname]容器启动成功！" -ForegroundColor Green
            Write-Host "当前容器状态：" -ForegroundColor Green
            docker ps -f "name=$cname" --format "Name:{{.Names}} Status:{{.Status}} Ports:{{.Ports}}"
        }
        else {
            Write-Host "❌ [$cname]容器启动失败，请检查命令或配置" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ 取消[$cname]原配置启动" -ForegroundColor Yellow
    }
}

# 手动自定义盘符/端口启动容器
function Start-ContainerWithCustomConfig($image, $cname) {
    Clear-Host
    Write-Host "🔧 手动自定义[$cname]容器配置" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    # 自定义容器名称（默认原名称）
    $newName = Read-Host "输入容器名称（默认：$cname）"
    if ([string]::IsNullOrEmpty($newName)) {
        $newName = $cname
    }

    # 自定义端口映射（支持多个，用逗号分隔）
    $portInput = Read-Host "输入端口映射（格式：主机端口:容器端口，多个用逗号分隔，如 8080:80,9090:90）"
    $ports = @()
    if (-not [string]::IsNullOrEmpty($portInput)) {
        $portList = $portInput -split ","
        foreach ($p in $portList) {
            $pParts = $p -split ":"
            if ($pParts.Count -eq 2) {
                $ports += @{HostPort = $pParts[0].Trim(); ContainerPort = $pParts[1].Trim()}
            }
            else {
                Write-Host "⚠️ 端口格式错误：$p，已忽略" -ForegroundColor Yellow
            }
        }
    }

    # 自定义盘符/目录挂载（支持多个，用逗号分隔）
    $volInput = Read-Host "输入挂载卷（格式：主机路径:容器路径，多个用逗号分隔，如 D:\memos:/data,C:\logs:/var/log）"
    $volumes = @()
    if (-not [string]::IsNullOrEmpty($volInput)) {
        $volList = $volInput -split ","
        foreach ($v in $volList) {
            $vParts = $v -split ":"
            if ($vParts.Count -eq 2) {
                $hostPath = $vParts[0].Trim()
                $containerPath = $vParts[1].Trim()
                # 确保主机路径存在
                if (-not (Test-Path $hostPath)) {
                    New-Item -ItemType Directory -Path $hostPath -Force | Out-Null
                    Write-Host "✅ 自动创建主机路径：$hostPath" -ForegroundColor Green
                }
                $volumes += @{HostPath = $hostPath; ContainerPath = $containerPath}
            }
            else {
                Write-Host "⚠️ 挂载格式错误：$v，已忽略" -ForegroundColor Yellow
            }
        }
    }

    # 自定义重启策略
    $restart = Read-Host "输入重启策略（always/on-failure/no，默认：always）"
    if ([string]::IsNullOrEmpty($restart)) {
        $restart = "always"
    }

    # 拼接启动命令
    $runCmd = "docker run -d --name $newName --restart=$restart"
    # 添加端口
    foreach ($port in $ports) {
        $runCmd += " -p $($port.HostPort):$($port.ContainerPort)"
    }
    # 添加挂载
    foreach ($vol in $volumes) {
        $runCmd += " -v $($vol.HostPath):$($vol.ContainerPath)"
    }
    # 追加镜像
    $runCmd += " $image"

    # 确认并执行
    Write-Host "`n=============================================" -ForegroundColor Cyan
    Write-Host "最终启动命令：$runCmd" -ForegroundColor Yellow
    $confirm = Read-Host "是否执行启动？(Y/N)"
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        Invoke-Expression $runCmd
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ [$newName]容器启动成功！" -ForegroundColor Green
            docker ps -f "name=$newName" --format "Name:{{.Names}} Status:{{.Status}} Ports:{{.Ports}}"
        }
        else {
            Write-Host "❌ [$newName]容器启动失败" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ 取消启动" -ForegroundColor Yellow
    }
}

# 导出容器（强制包含容器名，核心修复版）
function Start-Export {
    Clear-Host
    Write-Host "📦 容器导出 - 选择要迁移的容器" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    $containers = Get-ContainerInfo
    if ($containers.Count -eq 0) {
        Write-Host "❌ 未找到任何Docker容器" -ForegroundColor Red
        Read-Host "按回车返回"
        Show-MainMenu
    }

    # 显示Name/ID/Status列表
    Write-Host "序号 | 容器名称(Name) | 容器ID(ID)       | 状态(Status)" -ForegroundColor Green
    Write-Host "------------------------------------------------------------------------"
    foreach ($c in $containers) {
        $shortID = $c.ID.Substring(0, [Math]::Min(12, $c.ID.Length))
        Write-Host "$($c.Index.ToString().PadRight(4)) | $($c.Name.PadRight(13)) | $($shortID.PadRight(16)) | $($c.Status)"
    }
    Write-Host "------------------------------------------------------------------------"

    # 选择容器（强制校验，确保$cname有值）
    do {
        $selectedNum = Read-Host "请输入容器序号"
        $selectedContainer = $containers | Where-Object { $_.Index -eq [int]$selectedNum }
        if (-not $selectedContainer) {
            Write-Host "❌ 序号错误，请重新输入" -ForegroundColor Red
        }
    } while (-not $selectedContainer)

    # 强制赋值容器名，避免为空
    $cname = $selectedContainer.Name.Trim()
    if ([string]::IsNullOrEmpty($cname)) {
        Write-Host "❌ 容器名称为空，无法导出" -ForegroundColor Red
        Read-Host "按回车返回"
        Show-MainMenu
    }
    Write-Host "`n✅ 已选择容器：$cname" -ForegroundColor Green

    # 生成迁移目录（强制拼接容器名+时间戳）
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    # 核心修复：确保容器名必在目录名中
    $saveDir = "docker_migrate_$($cname)_$timestamp"
    $savePath = Join-Path (Get-Location) $saveDir
    New-Item -ItemType Directory -Path $savePath -Force | Out-Null

    # 导出镜像
    Write-Host "🔹 导出[$cname]镜像..." -ForegroundColor Yellow
    $image = docker inspect --format "{{.Config.Image}}" $cname
    docker save -o (Join-Path $savePath "image.tar") $image

    # 导出配置+写入容器名文件
    Write-Host "🔹 导出[$cname]容器配置..." -ForegroundColor Yellow
    docker inspect $cname | Out-File (Join-Path $savePath "config.json") -Encoding utf8
    $cname | Out-File (Join-Path $savePath "container_name.txt") -Encoding utf8

    # 打包（zip名强制包含容器名）
    Write-Host "🔹 打包[$cname]迁移文件..." -ForegroundColor Yellow
    $zipPath = Join-Path (Get-Location) "$saveDir.zip"
    Compress-Archive -Path $savePath -DestinationPath $zipPath -Force
    Remove-Item $savePath -Recurse -Force

    # 输出验证：明确显示带容器名的zip路径
    Write-Host "`n✅ 导出成功！" -ForegroundColor Green
    Write-Host "📦 迁移包：$zipPath" -ForegroundColor Green
    Write-Host "🔍 包名格式：docker_migrate_<容器名>_<时间戳>.zip" -ForegroundColor Green
    Read-Host "按回车返回主菜单"
    Show-MainMenu
}

# 导入容器（兼容含容器名的迁移包）
function Start-Import {
    Clear-Host
    Write-Host "📥 容器导入工具" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    $importPath = Read-Host "拖入解压后的迁移文件夹路径"
    # 核心修复：去除路径引号 + 标准化路径（自动处理末尾斜杠）
    $importPath = $importPath.Trim('"')
    $importPath = [System.IO.Path]::GetFullPath($importPath)

    # 校验路径是否为目录
    if (-not (Test-Path $importPath -PathType Container)) {
        Write-Host "❌ 路径不存在或不是文件夹：$importPath" -ForegroundColor Red
        Read-Host "按回车返回"
        Show-MainMenu
    }

    # 优先读取container_name.txt（确保容器名准确）
    $nameFile = Join-Path $importPath "container_name.txt"
    if (Test-Path $nameFile) {
        $cname = Get-Content $nameFile -Raw | Trim
        Write-Host "✅ 从迁移包识别容器名：$cname" -ForegroundColor Green
    }
    else {
        # 兼容旧版：从文件夹名解析
        $dirName = Split-Path $importPath -Leaf
        $cname = $dirName -replace "docker_migrate_", "" -replace "_\d{14}", ""
        Write-Host "⚠️ 未找到容器名文件，从文件夹名解析：$cname" -ForegroundColor Yellow
    }

    # 导入镜像（修复路径拼接逻辑）
    $imageTar = Join-Path $importPath "image.tar"
    $imageTar = [System.IO.Path]::GetFullPath($imageTar)
    
    if (-not (Test-Path $imageTar)) {
        Write-Host "❌ 未找到image.tar文件：$imageTar" -ForegroundColor Red
        Read-Host "按回车返回"
        Show-MainMenu
    }
    Write-Host "🔹 导入[$cname]镜像...（路径：$imageTar）" -ForegroundColor Yellow
    docker load -i $imageTar
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ [$cname]镜像导入成功！`n" -ForegroundColor Green
    }
    else {
        Write-Host "❌ [$cname]镜像导入失败" -ForegroundColor Red
        Read-Host "按回车返回"
        Show-MainMenu
    }

    # 导入后配置选择菜单
    Write-Host "🔧 [$cname]容器启动配置选择" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "1) 一键恢复原容器配置（端口/盘符/环境变量）"
    Write-Host "2) 手动自定义配置（映射盘符/端口）"
    Write-Host "3) 取消启动（仅完成镜像导入）"
    $configChoice = Read-Host "请选择 [1-3]"

    # 读取原配置文件
    $configPath = Join-Path $importPath "config.json"
    $configPath = [System.IO.Path]::GetFullPath($configPath)
    $originalConfig = Get-OriginalConfig $configPath $cname
    $image = if ($originalConfig) { $originalConfig.Image } else { (docker images --format "{{.Repository}}:{{.Tag}}" | Select-Object -Last 1) }

    switch ($configChoice) {
        1 {
            if ($originalConfig) {
                Start-ContainerWithOriginalConfig $originalConfig $cname
            }
            else {
                Write-Host "❌ 未找到[$cname]原配置文件，无法一键恢复" -ForegroundColor Red
                Start-ContainerWithCustomConfig $image $cname
            }
        }
        2 { Start-ContainerWithCustomConfig $image $cname }
        3 { Write-Host "⚠️ 已完成[$cname]镜像导入，未启动容器" -ForegroundColor Yellow }
        default { Write-Host "❌ 输入错误，取消启动" -ForegroundColor Red }
    }

    Read-Host "按回车返回主菜单"
    Show-MainMenu
}

# 主菜单
function Show-MainMenu {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "        Docker容器迁移工具（Windows版）" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "1) 导出容器（打包迁移，文件名含容器名）"
    Write-Host "2) 导入容器（支持一键恢复/自定义配置）"
    Write-Host "3) 退出"
    $choice = Read-Host "请选择操作 [1-3]"
    
    switch ($choice) {
        1 { Start-Export }
        2 { Start-Import }
        3 { exit 0 }
        default { 
            Write-Host "❌ 输入错误，请重新选择" -ForegroundColor Red
            Start-Sleep 1
            Show-MainMenu 
        }
    }
}

# 启动脚本
Test-DockerRunning
Show-MainMenu