-- 创建管理员账号 SQL
-- 用户名: admin
-- 密码: admin123

-- 注意：这个 bcrypt hash 对应密码 "admin123"
-- 如需更改密码，请运行 create-admin.ts 脚本

INSERT INTO "User" (username, password, "createdAt")
VALUES ('admin', '$2a$10$XN.KnZrF7bFJVqN3DnBvQu1iBrMHR/HtEYOqrb0kW9W5WxLF1gBjK', NOW())
ON CONFLICT (username) DO NOTHING;
