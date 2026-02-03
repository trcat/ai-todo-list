# 创建管理员账号
# 用于初始化系统管理员

Write-Host "🔐 创建管理员账号" -ForegroundColor Cyan
Write-Host ("=" * 50)

# 检查 .env 文件
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env 文件不存在" -ForegroundColor Red
    Write-Host "请先运行: vercel env pull .env" -ForegroundColor Yellow
    exit 1
}

# 获取管理员账号信息
Write-Host "`n📝 请输入管理员账号信息:" -ForegroundColor Yellow
$adminUsername = Read-Host "用户名 (默认: admin)"
if ([string]::IsNullOrWhiteSpace($adminUsername)) {
    $adminUsername = "admin"
}

$adminPassword = Read-Host "密码 (默认: admin123)" -AsSecureString
$adminPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPassword)
)
if ([string]::IsNullOrWhiteSpace($adminPasswordPlain)) {
    $adminPasswordPlain = "admin123"
}

Write-Host "`n🔧 正在创建管理员账号..." -ForegroundColor Yellow

# 设置环境变量并运行脚本
$env:ADMIN_USERNAME = $adminUsername
$env:ADMIN_PASSWORD = $adminPasswordPlain

# 使用 tsx 运行 TypeScript 脚本
pnpm tsx scripts/create-admin.ts

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ 管理员账号创建成功！" -ForegroundColor Green
    Write-Host "`n📋 登录信息:" -ForegroundColor Cyan
    Write-Host "  用户名: $adminUsername" -ForegroundColor White
    Write-Host "  密码: $adminPasswordPlain" -ForegroundColor White
    Write-Host "`n⚠️  请记录并妥善保管此信息！" -ForegroundColor Yellow
}
else {
    Write-Host "`n❌ 创建失败，请检查错误信息" -ForegroundColor Red
}
