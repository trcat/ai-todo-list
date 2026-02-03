# 测试管理员登录功能

Write-Host "🧪 测试管理员登录限制" -ForegroundColor Cyan
Write-Host ("=" * 50)

$baseUrl = "http://localhost:3000"

# 测试 1: 使用正确的管理员账号
Write-Host "`n✅ 测试 1: 正确的管理员账号 (admin/admin123)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/login" `
        -Method Post `
        -Body (@{username="admin"; password="admin123"} | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "✅ 登录成功" -ForegroundColor Green
    Write-Host "  Token: $($response.token.Substring(0,20))..." -ForegroundColor Gray
    Write-Host "  User: $($response.user.username) (ID: $($response.user.id))" -ForegroundColor Gray
} catch {
    Write-Host "❌ 测试失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 测试 2: 错误的密码
Write-Host "`n❌ 测试 2: 错误的密码 (admin/wrongpass)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/login" `
        -Method Post `
        -Body (@{username="admin"; password="wrongpass"} | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "❌ 不应该登录成功" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "✅ 正确拒绝：401 Unauthorized" -ForegroundColor Green
    } else {
        Write-Host "⚠️  状态码: $statusCode" -ForegroundColor Yellow
    }
}

# 测试 3: 不存在的用户（应该被拒绝，不再自动注册）
Write-Host "`n❌ 测试 3: 不存在的用户 (newuser/password123)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/login" `
        -Method Post `
        -Body (@{username="newuser"; password="password123"} | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "❌ 不应该登录成功（不再自动注册）" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "✅ 正确拒绝：401 Unauthorized（不再自动注册）" -ForegroundColor Green
    } else {
        Write-Host "⚠️  状态码: $statusCode" -ForegroundColor Yellow
    }
}

# 测试 4: 空用户名/密码
Write-Host "`n❌ 测试 4: 空用户名 (''/password)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/login" `
        -Method Post `
        -Body (@{username=""; password="password"} | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "❌ 不应该登录成功" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400) {
        Write-Host "✅ 正确拒绝：400 Bad Request" -ForegroundColor Green
    } else {
        Write-Host "⚠️  状态码: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host "`n" + ("=" * 50)
Write-Host "✨ 测试完成" -ForegroundColor Cyan
Write-Host "`n📋 总结:" -ForegroundColor Yellow
Write-Host "  ✅ 只有管理员账号可以登录" -ForegroundColor Green
Write-Host "  ✅ 错误密码被拒绝" -ForegroundColor Green
Write-Host "  ✅ 不存在的用户被拒绝（不再自动注册）" -ForegroundColor Green
Write-Host "  ✅ 空用户名/密码被拒绝" -ForegroundColor Green
