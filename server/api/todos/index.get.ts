import prisma from '~/server/utils/prisma'
import { extractToken, verifyToken } from '~/server/utils/jwt'

export default defineEventHandler(async (event) => {
  const authHeader = getHeader(event, 'authorization')
  const token = extractToken(authHeader || null)

  if (!token) {
    throw createError({
      statusCode: 401,
      message: '未授权'
    })
  }

  const payload = await verifyToken(token)

  if (!payload || !payload.userId) {
    throw createError({
      statusCode: 401,
      message: 'Token 无效'
    })
  }

  try {
    const todos = await prisma.todo.findMany({
      where: {
        userId: payload.userId as number
      },
      orderBy: {
        createdAt: 'desc'
      }
    })

    return todos
  } catch (error) {
    throw createError({
      statusCode: 500,
      message: '获取待办事项失败'
    })
  }
})
