<template>
  <div class="todo-container">
    <el-card class="todo-card">
      <template #header>
        <div class="card-header">
          <span>我的待办事项</span>
        </div>
      </template>
      
      <div class="add-todo">
        <el-input
          v-model="newTodo"
          placeholder="添加新的待办事项..."
          @keyup.enter="addTodo"
          clearable
        >
          <template #append>
            <el-button :icon="Plus" @click="addTodo">添加</el-button>
          </template>
        </el-input>
      </div>

      <div v-if="todos.length === 0" class="empty-state">
        <el-empty description="还没有待办事项，赶快添加一个吧！" />
      </div>

      <el-scrollbar v-else max-height="500px">
        <div class="todo-list">
          <div
            v-for="todo in todos"
            :key="todo.id"
            class="todo-item"
            :class="{ 'completed': todo.completed }"
          >
            <el-checkbox
              v-model="todo.completed"
              @change="toggleTodo(todo)"
              class="todo-checkbox"
            />
            <div class="todo-content" @click="toggleTodo(todo)">
              <div class="todo-text">{{ todo.text }}</div>
              <div v-if="todo.description" class="todo-description">
                {{ todo.description }}
              </div>
            </div>
            <el-button
              type="danger"
              :icon="Delete"
              circle
              size="small"
              @click="deleteTodo(todo.id)"
              class="delete-btn"
            />
          </div>
        </div>
      </el-scrollbar>

      <div v-if="todos.length > 0" class="todo-stats">
        <span>总计: {{ todos.length }} | 已完成: {{ completedCount }} | 未完成: {{ uncompletedCount }}</span>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, type Ref, type ComputedRef } from 'vue'
import { Plus, Delete } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

interface User {
  username: string
  [key: string]: any
}

interface Todo {
  id: string
  text: string
  description?: string
  completed: boolean
}

interface Props {
  user: User
}

interface Emits {
  (e: 'refresh'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const newTodo: Ref<string> = ref('')
const todos: Ref<Todo[]> = ref([])

const completedCount: ComputedRef<number> = computed(() => 
  todos.value.filter(todo => todo.completed).length
)

const uncompletedCount: ComputedRef<number> = computed(() => 
  todos.value.filter(todo => !todo.completed).length
)

onMounted(() => {
  loadTodos()
})

async function loadTodos(): Promise<void> {
  try {
    const token = useCookie('auth_token')
    const { data } = await useFetch<Todo[]>('/api/todos', {
      headers: {
        Authorization: `Bearer ${token.value}`
      }
    })
    if (data.value) {
      todos.value = data.value
    }
  } catch (error) {
    console.error('加载待办事项失败:', error)
  }
}

async function addTodo(): Promise<void> {
  if (!newTodo.value.trim()) {
    ElMessage.warning('请输入待办事项内容')
    return
  }

  try {
    const token = useCookie('auth_token')
    const { data, error } = await useFetch<Todo>('/api/todos', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token.value}`
      },
      body: {
        text: newTodo.value.trim()
      }
    })

    if (error.value) {
      ElMessage.error('添加失败')
      return
    }

    if (data.value) {
      todos.value.push(data.value)
      newTodo.value = ''
      ElMessage.success('添加成功')
    }
  } catch (err) {
    ElMessage.error('添加失败，请重试')
  }
}

async function toggleTodo(todo: Todo): Promise<void> {
  try {
    const token = useCookie('auth_token')
    await useFetch(`/api/todos/${todo.id}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token.value}`
      },
      body: {
        completed: todo.completed
      }
    })
  } catch (error) {
    console.error('更新待办事项失败:', error)
    todo.completed = !todo.completed
  }
}

async function deleteTodo(id: string): Promise<void> {
  try {
    const token = useCookie('auth_token')
    const { error } = await useFetch(`/api/todos/${id}`, {
      method: 'DELETE',
      headers: {
        Authorization: `Bearer ${token.value}`
      }
    })

    if (error.value) {
      ElMessage.error('删除失败')
      return
    }

    todos.value = todos.value.filter(todo => todo.id !== id)
    ElMessage.success('删除成功')
  } catch (err) {
    ElMessage.error('删除失败，请重试')
  }
}
</script>

<style scoped>
.todo-container {
  max-width: 800px;
  margin: 0 auto;
}

.todo-card {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.add-todo {
  margin-bottom: 20px;
}

.todo-list {
  padding: 10px 0;
}

.todo-item {
  display: flex;
  align-items: center;
  padding: 12px;
  margin-bottom: 8px;
  background-color: var(--bg-secondary);
  border-radius: 4px;
  transition: all 0.3s;
  border: 1px solid var(--border-color);
}

.todo-item:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.todo-item.completed {
  opacity: 0.6;
}

.todo-checkbox {
  margin-right: 12px;
}

.todo-content {
  flex: 1;
  cursor: pointer;
}

.todo-text {
  font-size: 14px;
  color: var(--text-primary);
}

.todo-item.completed .todo-text {
  text-decoration: line-through;
  color: var(--text-secondary);
}

.todo-description {
  font-size: 12px;
  color: var(--text-secondary);
  margin-top: 4px;
}

.delete-btn {
  margin-left: 8px;
}

.todo-stats {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-color);
  text-align: center;
  font-size: 14px;
  color: var(--text-secondary);
}

.empty-state {
  padding: 40px 0;
}

@media (max-width: 600px) {
  .todo-item {
    padding: 10px;
  }

  .todo-text {
    font-size: 13px;
  }

  .todo-description {
    font-size: 11px;
  }
}
</style>
