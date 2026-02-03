# 检查 Vercel 环境变量配置
# 快速诊断工具

Write-Host "🔍 Vercel 环境变量检查工具" -ForegroundColor Cyan
Write-Host "=" * 50

# 检查本地 .env
Write-Host "`n📁 检查本地环境变量..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content .env -Raw
    
    Write-Host "`n本地 .env 配置状态:" -ForegroundColor White
    
    if ($envContent -match "DATABASE_URL=(.+)") {
        $dbUrl = $Matches[1]
        if ($dbUrl -match "^postgresql://") {
            Write-Host "  ✅ DATABASE_URL: 已配置 (PostgreSQL)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  DATABASE_URL: 格式可能不正确" -ForegroundColor Yellow
            Write-Host "     应为: postgresql://..." -ForegroundColor Gray
        }
    } else {
        Write-Host "  ❌ DATABASE_URL: 未配置" -ForegroundColor Red
    }
    
    if ($envContent -match "JWT_SECRET=(.+)") {
        $jwtSecret = $Matches[1].Trim()
        $length = $jwtSecret.Length
        if ($length -ge 32) {
            Write-Host "  ✅ JWT_SECRET: 已配置 ($length 字符)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  JWT_SECRET: 太短 ($length 字符，建议至少 32)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ JWT_SECRET: 未配置" -ForegroundColor Red
    }
    
    if ($envContent -match "NODE_ENV=(.+)") {
        Write-Host "  ℹ️  NODE_ENV: $($Matches[1])" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ 本地 .env 文件不存在" -ForegroundColor Red
    Write-Host "运行 'vercel env pull .env' 拉取环境变量" -ForegroundColor Yellow
}

# 检查 Vercel 远程环境变量
Write-Host "`n☁️  检查 Vercel 远程环境变量..." -ForegroundColor Yellow

$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercelInstalled) {
    Write-Host "❌ 未安装 Vercel CLI" -ForegroundColor Red
    Write-Host "运行: pnpm add -g vercel" -ForegroundColor Yellow
    exit 1
}

if (Test-Path ".vercel") {
    Write-Host "`nProduction 环境:" -ForegroundColor White
    vercel env ls production 2>&1 | Select-String -Pattern "DATABASE_URL|JWT_SECRET|Found"
    
    Write-Host "`nPreview 环境:" -ForegroundColor White
    vercel env ls preview 2>&1 | Select-String -Pattern "DATABASE_URL|JWT_SECRET|Found"
} else {
    Write-Host "⚠️  项目未链接到 Vercel" -ForegroundColor Yellow
    Write-Host "运行 'vercel link' 链接项目" -ForegroundColor Yellow
}

# 测试数据库连接
Write-Host "`n🗄️  测试数据库连接..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $testResult = pnpm prisma db execute --stdin 2>&1 <<< "SELECT 1"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 数据库连接正常" -ForegroundColor Green
    } else {
        Write-Host "❌ 数据库连接失败" -ForegroundColor Red
        Write-Host "请检查 DATABASE_URL 是否正确" -ForegroundColor Yellow
    }
}

# 检查 Prisma Client
Write-Host "`n🔧 检查 Prisma Client..." -ForegroundColor Yellow
if (Test-Path "node_modules/.prisma/client") {
    Write-Host "✅ Prisma Client 已生成" -ForegroundColor Green
} else {
    Write-Host "❌ Prisma Client 未生成" -ForegroundColor Red
    Write-Host "运行: pnpm prisma generate" -ForegroundColor Yellow
}

# 检查最近的部署
Write-Host "`n🚀 最近的 Vercel 部署..." -ForegroundColor Yellow
if (Test-Path ".vercel") {
    vercel ls 2>&1 | Select-Object -First 5
}

Write-Host "`n" + "=" * 50
Write-Host "💡 快速修复命令:" -ForegroundColor Cyan
Write-Host "  1. 拉取环境变量:  vercel env pull .env" -ForegroundColor White
Write-Host "  2. 生成 Prisma:    pnpm prisma generate" -ForegroundColor White
Write-Host "  3. 推送数据库:     pnpm prisma db push" -ForegroundColor White
Write-Host "  4. 重新部署:       vercel --prod" -ForegroundColor White
Write-Host "`n  完整自动化:       .\setup-vercel.ps1" -ForegroundColor Green
