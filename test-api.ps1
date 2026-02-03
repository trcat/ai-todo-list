# 测试 Vercel 部署的 API 接口
# 用于验证登录功能是否正常

param(
    [string]$Url = "",
    [string]$Username = "testuser",
    [string]$Password = "test123"
)

Write-Host "🧪 API 测试工具" -ForegroundColor Cyan
Write-Host "=" * 50

# 获取部署 URL
if ($Url -eq "") {
    Write-Host "`n📡 获取 Vercel 部署 URL..." -ForegroundColor Yellow
    
    if (Test-Path ".vercel") {
        $deploymentInfo = vercel ls --json 2>&1 | ConvertFrom-Json
        if ($deploymentInfo -and $deploymentInfo.deployments) {
            $latestDeployment = $deploymentInfo.deployments[0]
            $Url = "https://$($latestDeployment.url)"
            Write-Host "✅ 找到最新部署: $Url" -ForegroundColor Green
        } else {
            Write-Host "❌ 无法获取部署信息" -ForegroundColor Red
            $Url = Read-Host "请输入你的 Vercel 部署 URL (例: https://your-app.vercel.app)"
        }
    } else {
        $Url = Read-Host "请输入你的 Vercel 部署 URL (例: https://your-app.vercel.app)"
    }
}

$Url = $Url.TrimEnd('/')

Write-Host "`n目标 URL: $Url" -ForegroundColor White
Write-Host "用户名: $Username" -ForegroundColor White
Write-Host "密码: $Password" -ForegroundColor White

# 测试健康检查
Write-Host "`n🏥 测试健康检查..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "$Url/api/health" -Method Get -ErrorAction Stop
    Write-Host "✅ 健康检查通过" -ForegroundColor Green
    Write-Host "响应: $($healthResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "⚠️  健康检查失败或接口不存在" -ForegroundColor Yellow
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
}

# 测试登录接口
Write-Host "`n🔐 测试登录接口..." -ForegroundColor Yellow
$loginBody = @{
    username = $Username
    password = $Password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod `
        -Uri "$Url/api/auth/login" `
        -Method Post `
        -Body $loginBody `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "✅ 登录成功！" -ForegroundColor Green
    Write-Host "`n返回数据:" -ForegroundColor White
    Write-Host "  Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "  User ID: $($loginResponse.user.id)" -ForegroundColor Gray
    Write-Host "  Username: $($loginResponse.user.username)" -ForegroundColor Gray
    
    $token = $loginResponse.token
    
    # 测试获取用户信息
    Write-Host "`n👤 测试获取用户信息..." -ForegroundColor Yellow
    try {
        $meResponse = Invoke-RestMethod `
            -Uri "$Url/api/auth/me" `
            -Method Get `
            -Headers @{ Authorization = "Bearer $token" } `
            -ErrorAction Stop
        
        Write-Host "✅ 获取用户信息成功" -ForegroundColor Green
        Write-Host "  User: $($meResponse.user.username) (ID: $($meResponse.user.id))" -ForegroundColor Gray
    } catch {
        Write-Host "❌ 获取用户信息失败" -ForegroundColor Red
        Write-Host "状态码: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
    
    # 测试待办事项接口
    Write-Host "`n📝 测试待办事项接口..." -ForegroundColor Yellow
    try {
        $todosResponse = Invoke-RestMethod `
            -Uri "$Url/api/todos" `
            -Method Get `
            -Headers @{ Authorization = "Bearer $token" } `
            -ErrorAction Stop
        
        Write-Host "✅ 获取待办事项成功" -ForegroundColor Green
        Write-Host "  待办数量: $($todosResponse.todos.Count)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ 获取待办事项失败" -ForegroundColor Red
        Write-Host "状态码: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
    
    # 测试创建待办
    Write-Host "`n➕ 测试创建待办..." -ForegroundColor Yellow
    $createTodoBody = @{
        text = "测试任务 $(Get-Date -Format 'HH:mm:ss')"
        description = "通过 PowerShell 脚本创建"
        priority = "high"
    } | ConvertTo-Json
    
    try {
        $createResponse = Invoke-RestMethod `
            -Uri "$Url/api/todos" `
            -Method Post `
            -Body $createTodoBody `
            -ContentType "application/json" `
            -Headers @{ Authorization = "Bearer $token" } `
            -ErrorAction Stop
        
        Write-Host "✅ 创建待办成功" -ForegroundColor Green
        Write-Host "  ID: $($createResponse.todo.id)" -ForegroundColor Gray
        Write-Host "  内容: $($createResponse.todo.text)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ 创建待办失败" -ForegroundColor Red
        Write-Host "状态码: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ 登录失败！" -ForegroundColor Red
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "状态码: $statusCode" -ForegroundColor Red
    
    if ($statusCode -eq 500) {
        Write-Host "`n⚠️  500 错误可能原因:" -ForegroundColor Yellow
        Write-Host "  1. 环境变量未配置 (DATABASE_URL, JWT_SECRET)" -ForegroundColor White
        Write-Host "  2. 数据库连接失败" -ForegroundColor White
        Write-Host "  3. Prisma Client 未生成" -ForegroundColor White
        Write-Host "`n💡 解决方案:" -ForegroundColor Cyan
        Write-Host "  运行: .\setup-vercel.ps1" -ForegroundColor Green
    }
    
    try {
        $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "错误详情: $($errorBody.message)" -ForegroundColor Red
    } catch {
        Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n" + "=" * 50
Write-Host "📊 测试完成" -ForegroundColor Cyan
Write-Host "`n查看详细日志: vercel logs" -ForegroundColor Yellow
Write-Host "查看 Vercel Dashboard: https://vercel.com/dashboard" -ForegroundColor Cyan
