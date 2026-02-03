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
    const user = await prisma.user.findUnique({
      where: { username }
    })

    // 用户不存在
    if (!user) {
      throw createError({
        statusCode: 401,
        message: '用户名或密码错误'
      })
    }

    // 验证密码
    const isValid = await comparePassword(password, user.password)
    
    if (!isValid) {
      throw createError({
        statusCode: 401,
        message: '用户名或密码错误'
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
