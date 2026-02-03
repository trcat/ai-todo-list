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

  const id = parseInt(event.context.params?.id || '0')
  
  if (!id) {
    throw createError({
      statusCode: 400,
      message: '无效的待办事项 ID'
    })
  }

  try {
    // 验证待办事项是否属于当前用户
    const todo = await prisma.todo.findUnique({
      where: { id }
    })

    if (!todo || todo.userId !== payload.userId) {
      throw createError({
        statusCode: 404,
        message: '待办事项不存在'
      })
    }

    // 删除待办事项
    await prisma.todo.delete({
      where: { id }
    })

    return { success: true }
  } catch (error: any) {
    if (error.statusCode) {
      throw error
    }
    throw createError({
      statusCode: 500,
      message: '删除待办事项失败'
    })
  }
})
