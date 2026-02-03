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

  if (!payload) {
    throw createError({
      statusCode: 401,
      message: 'Token 无效'
    })
  }

  return {
    id: payload.userId,
    username: payload.username
  }
})
