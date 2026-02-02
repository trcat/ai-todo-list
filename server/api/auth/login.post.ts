import prisma from '~/server/utils/prisma'
import { hashPassword, comparePassword } from '~/server/utils/password'
import { signToken } from '~/server/utils/jwt'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { username, password } = body

  if (!username || !password) {
    throw createError({
      statusCode: 400,
      message: '用户名和密码不能为空'
    })
  }

  try {
    // 查找用户
    let user = await prisma.user.findUnique({
      where: { username }
    })

    // 如果用户不存在，自动注册
    if (!user) {
      const hashedPassword = await hashPassword(password)
      user = await prisma.user.create({
        data: {
          username,
          password: hashedPassword
        }
      })
      
      const token = await signToken({ userId: user.id, username: user.username })
      
      return {
        token,
        user: {
          id: user.id,
          username: user.username
        }
      }
    }

    // 用户存在，验证密码
    const isValid = await comparePassword(password, user.password)
    
    if (!isValid) {
      throw createError({
        statusCode: 401,
        message: '密码错误'
      })
    }

    const token = await signToken({ userId: user.id, username: user.username })

    return {
      token,
      user: {
        id: user.id,
        username: user.username
      }
    }
  } catch (error: any) {
    if (error.statusCode) {
      throw error
    }
    throw createError({
      statusCode: 500,
      message: '登录失败'
    })
  }
})
