# Vercel 部署配置自动化脚本
# 用于解决登录接口 500 错误

Write-Host "🚀 Vercel 部署配置助手" -ForegroundColor Cyan
Write-Host ("=" * 50)

# 检查 Vercel CLI
Write-Host "`n📦 检查 Vercel CLI..." -ForegroundColor Yellow
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercelInstalled) {
    Write-Host "❌ 未安装 Vercel CLI" -ForegroundColor Red
    Write-Host "正在安装..." -ForegroundColor Yellow
    pnpm add -g vercel
    Write-Host "✅ Vercel CLI 安装完成" -ForegroundColor Green
}
else {
    Write-Host "✅ Vercel CLI 已安装" -ForegroundColor Green
}

# 检查是否已登录
Write-Host "`n🔐 检查登录状态..." -ForegroundColor Yellow
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "需要登录 Vercel..." -ForegroundColor Yellow
    vercel login
}
else {
    Write-Host "✅ 已登录: $whoami" -ForegroundColor Green
}

# 链接项目
Write-Host "`n🔗 链接 Vercel 项目..." -ForegroundColor Yellow
if (-not (Test-Path ".vercel")) {
    Write-Host "首次配置，需要选择项目..." -ForegroundColor Yellow
    vercel link
}
else {
    Write-Host "✅ 项目已链接" -ForegroundColor Green
}

# 拉取环境变量
Write-Host "`n⬇️  拉取环境变量..." -ForegroundColor Yellow
vercel env pull .env
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 环境变量已拉取到 .env" -ForegroundColor Green
}
else {
    Write-Host "⚠️  拉取环境变量失败" -ForegroundColor Red
    Write-Host "请确保在 Vercel Dashboard 中配置了以下环境变量：" -ForegroundColor Yellow
    Write-Host "  - DATABASE_URL" -ForegroundColor White
    Write-Host "  - JWT_SECRET" -ForegroundColor White
    Write-Host "`n访问: https://vercel.com/dashboard" -ForegroundColor Cyan
    exit 1
}

# 检查环境变量
Write-Host "`n🔍 验证环境变量..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content .env -Raw
    $hasDatabaseUrl = $envContent -match "DATABASE_URL"
    $hasJwtSecret = $envContent -match "JWT_SECRET"
    
    if ($hasDatabaseUrl) {
        Write-Host "  ✅ DATABASE_URL 已配置" -ForegroundColor Green
    }
    else {
        Write-Host "  ❌ DATABASE_URL 未配置" -ForegroundColor Red
    }
    
    if ($hasJwtSecret) {
        Write-Host "  ✅ JWT_SECRET 已配置" -ForegroundColor Green
    }
    else {
        Write-Host "  ❌ JWT_SECRET 未配置" -ForegroundColor Red
    }
    
    if (-not $hasDatabaseUrl -or -not $hasJwtSecret) {
        Write-Host "`n请在 Vercel Dashboard 添加缺失的环境变量后重新运行此脚本" -ForegroundColor Red
        Write-Host "访问: https://vercel.com/dashboard → 项目 → Settings → Environment Variables" -ForegroundColor Cyan
        exit 1
    }
}
else {
    Write-Host "❌ .env 文件不存在" -ForegroundColor Red
    exit 1
}

# 安装依赖
Write-Host "`n📦 安装依赖..." -ForegroundColor Yellow
pnpm install
Write-Host "✅ 依赖安装完成" -ForegroundColor Green

# 生成 Prisma Client
Write-Host "`n🔧 生成 Prisma Client..." -ForegroundColor Yellow
pnpm prisma generate
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Prisma Client 生成完成" -ForegroundColor Green
}
else {
    Write-Host "❌ Prisma Client 生成失败" -ForegroundColor Red
    exit 1
}

# 推送数据库 Schema
Write-Host "`n🗄️  初始化数据库..." -ForegroundColor Yellow
Write-Host "这将在远程数据库创建表结构" -ForegroundColor White
$confirm = Read-Host "继续? (Y/n)"
if ($confirm -eq "" -or $confirm -eq "Y" -or $confirm -eq "y") {
    pnpm prisma db push
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 数据库初始化完成" -ForegroundColor Green
    }
    else {
        Write-Host "❌ 数据库初始化失败" -ForegroundColor Red
        Write-Host "请检查 DATABASE_URL 是否正确" -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "⏭️  跳过数据库初始化" -ForegroundColor Yellow
}

# 提交更改
Write-Host "`n📝 提交配置更改..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "检测到未提交的更改" -ForegroundColor White
    git add .
    git commit -m "fix: configure prisma for vercel deployment"
    Write-Host "✅ 更改已提交" -ForegroundColor Green
    
    # 推送到远程
    Write-Host "`n🚀 推送到 GitHub..." -ForegroundColor Yellow
    git push
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 代码已推送，Vercel 将自动部署" -ForegroundColor Green
    }
    else {
        Write-Host "❌ 推送失败" -ForegroundColor Red
    }
}
else {
    Write-Host "✅ 没有需要提交的更改" -ForegroundColor Green
}

# 显示部署状态
Write-Host "`n📊 查看部署状态..." -ForegroundColor Yellow
Write-Host "访问 Vercel Dashboard 查看部署进度:" -ForegroundColor White
Write-Host "https://vercel.com/dashboard" -ForegroundColor Cyan

Write-Host ("`n" + ("=" * 50))
Write-Host "✨ 配置完成！" -ForegroundColor Green
Write-Host "`n下一步:" -ForegroundColor Yellow
Write-Host "1. 等待 Vercel 自动部署完成 (约 1-2 分钟)" -ForegroundColor White
Write-Host "2. 访问你的应用测试登录功能" -ForegroundColor White
Write-Host "3. 如仍有问题，查看 Vercel Functions 日志" -ForegroundColor White
Write-Host "`n💡 提示: 运行 'vercel logs' 查看实时日志" -ForegroundColor Cyan
