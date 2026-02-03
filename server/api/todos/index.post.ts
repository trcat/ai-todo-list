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

  const body = await readBody(event)
  const { text, description, priority } = body

  if (!text || !text.trim()) {
    throw createError({
      statusCode: 400,
      message: '待办事项内容不能为空'
    })
  }

  try {
    const todo = await prisma.todo.create({
      data: {
        text: text.trim(),
        description: description || '',
        priority: priority || 'medium',
        completed: false,
        userId: payload.userId as number
      }
    })

    return todo
  } catch (error) {
    throw createError({
      statusCode: 500,
      message: '创建待办事项失败'
    })
  }
})
