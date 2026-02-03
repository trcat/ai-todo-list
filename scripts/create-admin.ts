// 创建管理员账号脚本
import { PrismaClient } from '@prisma/client'
import { hashPassword } from '../server/utils/password'

const prisma = new PrismaClient()

async function main() {
  const adminUsername = process.env.ADMIN_USERNAME || 'admin'
  const adminPassword = process.env.ADMIN_PASSWORD || 'admin123'

  console.log('🔐 正在创建管理员账号...')
  console.log('用户名:', adminUsername)

  // 检查是否已存在
  const existingUser = await prisma.user.findUnique({
    where: { username: adminUsername }
  })

  if (existingUser) {
    console.log('⚠️  管理员账号已存在')
    console.log('用户 ID:', existingUser.id)
    console.log('创建时间:', existingUser.createdAt)
    return
  }

  // 创建管理员账号
  const hashedPassword = await hashPassword(adminPassword)
  const admin = await prisma.user.create({
    data: {
      username: adminUsername,
      password: hashedPassword
    }
  })

  console.log('✅ 管理员账号创建成功！')
  console.log('用户 ID:', admin.id)
  console.log('用户名:', admin.username)
  console.log('⚠️  请妥善保管密码:', adminPassword)
}

main()
  .catch((e) => {
    console.error('❌ 创建管理员账号失败:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
