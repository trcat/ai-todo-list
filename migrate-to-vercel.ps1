#!/usr/bin/env pwsh
# Vercel 迁移脚本

Write-Host "==============================================`n" -ForegroundColor Cyan
Write-Host "  🚀 Vercel + PostgreSQL 迁移向导`n" -ForegroundColor Cyan  
Write-Host "==============================================" -ForegroundColor Cyan

# 检查必要文件
Write-Host "`n[1/6] 检查配置文件..." -ForegroundColor Yellow
$allGood = $true

if (Test-Path "prisma/schema.prisma") {
    $content = Get-Content "prisma/schema.prisma" -Raw
    if ($content -match 'provider\s*=\s*"postgresql"') {
        Write-Host "  ✅ Prisma schema 已配置为 PostgreSQL" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Prisma schema 仍是 SQLite" -ForegroundColor Red
        $allGood = $false
    }
} else {
    Write-Host "  ❌ 找不到 prisma/schema.prisma" -ForegroundColor Red
    $allGood = $false
}

if (Test-Path "nuxt.config.ts") {
    Write-Host "  ✅ nuxt.config.ts 存在" -ForegroundColor Green
} else {
    Write-Host "  ❌ 找不到 nuxt.config.ts" -ForegroundColor Red
    $allGood = $false
}

if (Test-Path "vercel.json") {
    Write-Host "  ✅ vercel.json 已创建" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  建议创建 vercel.json" -ForegroundColor Yellow
}

if (-not $allGood) {
    Write-Host "`n❌ 配置文件有问题，请先运行 git pull 获取最新代码" -ForegroundColor Red
    exit 1
}

# 步骤 2: 数据库连接
Write-Host "`n[2/6] 配置数据库连接" -ForegroundColor Yellow
Write-Host "`n请访问 https://neon.tech 注册并创建数据库" -ForegroundColor Cyan
Write-Host "需要操作:" -ForegroundColor White
Write-Host "  1. 使用 GitHub 登录" -ForegroundColor Gray
Write-Host "  2. 创建新项目 (hello-vue-db)" -ForegroundColor Gray
Write-Host "  3. 复制连接字符串" -ForegroundColor Gray

$dbUrl = Read-Host "`n请粘贴你的 DATABASE_URL"

if (-not $dbUrl) {
    Write-Host "❌ 未输入 DATABASE_URL，退出" -ForegroundColor Red
    exit 1
}

if ($dbUrl -notmatch "^postgresql://") {
    Write-Host "⚠️  连接字符串应该以 postgresql:// 开头" -ForegroundColor Yellow
}

# 步骤 3: JWT 密钥
Write-Host "`n[3/6] 生成 JWT 密钥" -ForegroundColor Yellow
$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
Write-Host "生成的密钥: " -NoNewline -ForegroundColor White
Write-Host $jwtSecret -ForegroundColor Green

# 创建或更新 .env
Write-Host "`n[4/6] 更新 .env 文件..." -ForegroundColor Yellow
$envContent = @"
# 数据库连接字符串（PostgreSQL）
DATABASE_URL="$dbUrl"

# JWT 密钥
JWT_SECRET="$jwtSecret"

# 环境
NODE_ENV="development"
"@

Set-Content -Path ".env" -Value $envContent
Write-Host "  ✅ .env 文件已更新" -ForegroundColor Green

# 步骤 4: 测试数据库
Write-Host "`n[5/6] 测试数据库连接..." -ForegroundColor Yellow
Write-Host "  执行: pnpm prisma generate" -ForegroundColor Gray

try {
    $output = pnpm prisma generate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Prisma 客户端生成成功" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Prisma 客户端生成失败" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ❌ 执行失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n  执行: pnpm prisma db push" -ForegroundColor Gray
try {
    $output = pnpm prisma db push --accept-data-loss 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ 数据库结构同步成功" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 数据库同步失败" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        Write-Host "`n请检查:" -ForegroundColor Yellow
        Write-Host "  1. DATABASE_URL 是否正确" -ForegroundColor Gray
        Write-Host "  2. 网络连接是否正常" -ForegroundColor Gray
        Write-Host "  3. Neon 数据库是否处于 Active 状态" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "  ❌ 执行失败: $_" -ForegroundColor Red
    exit 1
}

# 步骤 5: 本地测试
Write-Host "`n[6/6] 准备部署" -ForegroundColor Yellow
Write-Host "`n是否启动本地测试? (y/n)" -ForegroundColor Cyan
$test = Read-Host

if ($test -eq "y" -or $test -eq "Y") {
    Write-Host "`n启动开发服务器..." -ForegroundColor Green
    Write-Host "访问 http://localhost:3000 测试应用" -ForegroundColor Cyan
    Write-Host "按 Ctrl+C 停止服务器后继续部署步骤`n" -ForegroundColor Gray
    pnpm dev
}

# 部署说明
Write-Host "`n==============================================`n" -ForegroundColor Cyan
Write-Host "  ✅ 迁移准备完成！`n" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host "`n📝 环境变量（部署时需要）:" -ForegroundColor Yellow
Write-Host "DATABASE_URL: " -NoNewline -ForegroundColor White
Write-Host $dbUrl -ForegroundColor Gray
Write-Host "JWT_SECRET: " -NoNewline -ForegroundColor White
Write-Host $jwtSecret -ForegroundColor Gray

Write-Host "`n🚀 部署到 Vercel:" -ForegroundColor Yellow
Write-Host "`n方法 1: 通过网页 (推荐)" -ForegroundColor Cyan
Write-Host "  1. git add . && git commit -m 'feat: 迁移到 PostgreSQL' && git push" -ForegroundColor White
Write-Host "  2. 访问 https://vercel.com/new" -ForegroundColor White
Write-Host "  3. 导入 GitHub 仓库" -ForegroundColor White
Write-Host "  4. 添加上面的环境变量" -ForegroundColor White
Write-Host "  5. 点击 Deploy" -ForegroundColor White

Write-Host "`n方法 2: 通过 CLI" -ForegroundColor Cyan
Write-Host "  npm i -g vercel" -ForegroundColor White
Write-Host "  vercel login" -ForegroundColor White
Write-Host "  vercel env add DATABASE_URL production" -ForegroundColor White
Write-Host "  vercel env add JWT_SECRET production" -ForegroundColor White
Write-Host "  vercel --prod" -ForegroundColor White

Write-Host "`n==============================================`n" -ForegroundColor Cyan
