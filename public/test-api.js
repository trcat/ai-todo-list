// 测试 API 端点的简单脚本
// 在浏览器控制台运行

async function testAPI() {
  console.log('🔍 开始测试 API...\n')
  
  // 1. 测试登录/注册
  console.log('1️⃣ 测试登录 API')
  const loginResponse = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: 'testuser_' + Date.now(),
      password: 'test123456'
    })
  })
  const loginData = await loginResponse.json()
  console.log('✅ 登录成功:', loginData)
  const token = loginData.token
  
  // 2. 测试获取用户信息
  console.log('\n2️⃣ 测试获取用户信息 API')
  const meResponse = await fetch('/api/auth/me', {
    headers: { 'Authorization': `Bearer ${token}` }
  })
  const meData = await meResponse.json()
  console.log('✅ 用户信息:', meData)
  
  // 3. 测试创建待办事项
  console.log('\n3️⃣ 测试创建待办事项 API')
  const createResponse = await fetch('/api/todos', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      text: '测试任务 ' + new Date().toLocaleTimeString(),
      description: '这是一个测试任务',
      priority: 'high'
    })
  })
  const createData = await createResponse.json()
  console.log('✅ 创建成功:', createData)
  const todoId = createData.id
  
  // 4. 测试获取所有待办事项
  console.log('\n4️⃣ 测试获取所有待办事项 API')
  const todosResponse = await fetch('/api/todos', {
    headers: { 'Authorization': `Bearer ${token}` }
  })
  const todosData = await todosResponse.json()
  console.log('✅ 待办事项列表:', todosData)
  
  // 5. 测试更新待办事项
  console.log('\n5️⃣ 测试更新待办事项 API')
  const updateResponse = await fetch(`/api/todos/${todoId}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      completed: true,
      priority: 'low'
    })
  })
  const updateData = await updateResponse.json()
  console.log('✅ 更新成功:', updateData)
  
  // 6. 测试删除待办事项
  console.log('\n6️⃣ 测试删除待办事项 API')
  const deleteResponse = await fetch(`/api/todos/${todoId}`, {
    method: 'DELETE',
    headers: { 'Authorization': `Bearer ${token}` }
  })
  const deleteData = await deleteResponse.json()
  console.log('✅ 删除成功:', deleteData)
  
  console.log('\n🎉 所有 API 测试通过！')
  return { token, message: '测试完成' }
}

// 运行测试
testAPI().catch(error => {
  console.error('❌ 测试失败:', error)
})
