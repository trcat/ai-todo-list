<template>
  <el-card class="box-card">
    <template #header>
      <div class="card-header">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span>{{ user.username }} 的待办事项</span>
          <el-button 
            v-if="completedTodos.length > 0" 
            type="danger" 
            size="small" 
            plain
            @click="clearCompleted"
          >
            清除已完成
          </el-button>
        </div>
        <form @submit.prevent="addTask" style="display: flex; gap: 10px; margin-top: 15px;">
          <el-select v-model="newTaskPriority" placeholder="优先级" style="width: 100px;">
            <el-option label="低" value="low" />
            <el-option label="中" value="medium" />
            <el-option label="高" value="high" />
          </el-select>
          <el-input
            ref="taskInput"
            v-model="newTask"
            placeholder="请输入待办事项..."
            @keydown.enter="handleEnter"
          >
            <template #append>
              <el-button @click="addTask">添加</el-button>
            </template>
          </el-input>
        </form>
      </div>
    </template>
    
    <el-empty v-if="todos.length === 0" description="暂无待办事项，快去添加一个吧！" />

    <div v-else>
      <!-- 未完成的任务 -->
      <div v-if="incompleteTodos.length > 0">
        <div class="section-title">进行中 ({{ incompleteTodos.length }})</div>
        <div v-for="todo in incompleteTodos" :key="todo.id" class="todo-item-wrapper">
          <div class="text item todo-item">
            <div style="display: flex; align-items: center; gap: 8px; flex: 1;">
              <el-checkbox v-model="todo.completed" @change="toggleTodo(todo)">
                <span :class="{ completed: todo.completed }">{{ todo.text }}</span>
              </el-checkbox>
              <el-tag :type="getPriorityType(todo.priority)" size="small">
                {{ getPriorityLabel(todo.priority) }}
              </el-tag>
            </div>
            <div class="todo-actions">
              <el-button type="warning" text size="small" @click="openPriorityDialog(todo)">
                优先级
              </el-button>
              <el-button type="info" text size="small" @click="openDescriptionDialog(todo)">
                {{ todo.description ? '查看' : '添加' }}描述
              </el-button>
              <el-button type="danger" icon="Delete" circle size="small" @click="removeTask(todo.id)" />
            </div>
          </div>
          <div v-if="todo.description" class="todo-description">{{ todo.description }}</div>
        </div>
      </div>

      <!-- 已完成的任务 -->
      <div v-if="completedTodos.length > 0">
        <div class="section-title">已完成 ({{ completedTodos.length }})</div>
        <div v-for="todo in completedTodos" :key="todo.id" class="todo-item-wrapper completed-section">
          <div class="text item todo-item">
            <el-checkbox v-model="todo.completed" @change="toggleTodo(todo)">
              <span :class="{ completed: todo.completed }">{{ todo.text }}</span>
            </el-checkbox>
            <div class="todo-actions">
              <el-button type="info" text size="small" @click="openDescriptionDialog(todo)">
                {{ todo.description ? '查看' : '添加' }}描述
              </el-button>
              <el-button type="danger" icon="Delete" circle size="small" @click="removeTask(todo.id)" />
            </div>
          </div>
          <div v-if="todo.description" class="todo-description">{{ todo.description }}</div>
        </div>
      </div>
    </div>

    <!-- 描述编辑对话框 -->
    <el-dialog v-model="showDescriptionDialog" title="编辑描述" width="300px" class="todo-dialog">
      <el-input
        v-model="tempDescription"
        type="textarea"
        :rows="4"
        placeholder="输入任务描述..."
      />
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showDescriptionDialog = false">取消</el-button>
          <el-button type="primary" @click="saveDescription">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 优先级编辑对话框 -->
    <el-dialog v-model="showPriorityDialog" title="设置优先级" width="300px" class="todo-dialog">
      <el-radio-group v-model="tempPriority">
        <el-radio label="low">低</el-radio>
        <el-radio label="medium">中</el-radio>
        <el-radio label="high">高</el-radio>
      </el-radio-group>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showPriorityDialog = false">取消</el-button>
          <el-button type="primary" @click="savePriority">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['refresh'])

const newTask = ref('')
const newTaskPriority = ref('medium')
const todos = ref([])
const editingTodo = ref(null)
const showDescriptionDialog = ref(false)
const tempDescription = ref('')
const showPriorityDialog = ref(false)
const tempPriority = ref('medium')
const taskInput = ref(null)

const incompleteTodos = computed(() => {
  const priorityOrder = { high: 1, medium: 2, low: 3 }
  return todos.value
    .filter(todo => !todo.completed)
    .sort((a, b) => priorityOrder[a.priority || 'medium'] - priorityOrder[b.priority || 'medium'])
})

const completedTodos = computed(() => {
  return todos.value.filter(todo => todo.completed)
})

onMounted(() => {
  loadTodos()
})

async function loadTodos() {
  try {
    const token = useCookie('auth_token')
    const { data, error } = await useFetch('/api/todos', {
      headers: {
        Authorization: `Bearer ${token.value}`
      }
    })
    
    if (error.value) {
      ElMessage.error('加载待办事项失败')
      return
    }
    
    todos.value = data.value || []
  } catch (err) {
    ElMessage.error('加载待办事项失败')
  }
}

function handleEnter(event) {
  event.preventDefault()
  event.stopPropagation()
  
  if (event.isComposing || event.keyCode === 229) {
    return
  }
  
  addTask()
}

async function addTask() {
  if (!newTask.value.trim()) {
    ElMessage.warning('请输入内容')
    return
  }
  
  try {
    const token = useCookie('auth_token')
    const { data, error } = await useFetch('/api/todos', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token.value}`
      },
      body: {
        text: newTask.value,
        priority: newTaskPriority.value
      }
    })
    
    if (error.value) {
      ElMessage.error('添加失败')
      return
    }
    
    todos.value.push(data.value)
    newTask.value = ''
    newTaskPriority.value = 'medium'
    ElMessage.success('已添加')
    
    nextTick(() => {
      if (taskInput.value) {
        taskInput.value.focus()
      }
    })
  } catch (err) {
    ElMessage.error('添加失败')
  }
}

async function toggleTodo(todo) {
  try {
    const token = useCookie('auth_token')
    const { error } = await useFetch(`/api/todos/${todo.id}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token.value}`
      },
      body: {
        completed: todo.completed
      }
    })
    
    if (error.value) {
      ElMessage.error('更新失败')
      todo.completed = !todo.completed
    }
  } catch (err) {
    ElMessage.error('更新失败')
    todo.completed = !todo.completed
  }
}

function removeTask(id) {
  ElMessageBox.confirm(
    '确定要删除这个待办事项吗？',
    '删除确认',
    {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
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
      ElMessage.success('已删除')
    } catch (err) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

function openDescriptionDialog(todo) {
  editingTodo.value = todo
  tempDescription.value = todo.description || ''
  showDescriptionDialog.value = true
}

async function saveDescription() {
  if (!editingTodo.value) return
  
  try {
    const token = useCookie('auth_token')
    const { error } = await useFetch(`/api/todos/${editingTodo.value.id}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token.value}`
      },
      body: {
        description: tempDescription.value
      }
    })
    
    if (error.value) {
      ElMessage.error('保存失败')
      return
    }
    
    editingTodo.value.description = tempDescription.value
    showDescriptionDialog.value = false
    ElMessage.success('描述已保存')
  } catch (err) {
    ElMessage.error('保存失败')
  }
}

function openPriorityDialog(todo) {
  editingTodo.value = todo
  tempPriority.value = todo.priority || 'medium'
  showPriorityDialog.value = true
}

async function savePriority() {
  if (!editingTodo.value) return
  
  try {
    const token = useCookie('auth_token')
    const { error } = await useFetch(`/api/todos/${editingTodo.value.id}`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token.value}`
      },
      body: {
        priority: tempPriority.value
      }
    })
    
    if (error.value) {
      ElMessage.error('更新失败')
      return
    }
    
    editingTodo.value.priority = tempPriority.value
    showPriorityDialog.value = false
    ElMessage.success('优先级已更新')
  } catch (err) {
    ElMessage.error('更新失败')
  }
}

async function clearCompleted() {
  const completedIds = completedTodos.value.map(t => t.id)
  
  try {
    const token = useCookie('auth_token')
    await Promise.all(
      completedIds.map(id => 
        useFetch(`/api/todos/${id}`, {
          method: 'DELETE',
          headers: {
            Authorization: `Bearer ${token.value}`
          }
        })
      )
    )
    
    const count = completedTodos.value.length
    todos.value = todos.value.filter(todo => !todo.completed)
    ElMessage.success(`已清除 ${count} 个已完成任务`)
  } catch (err) {
    ElMessage.error('清除失败')
  }
}

function getPriorityType(priority) {
  const types = { high: 'danger', medium: 'warning', low: 'info' }
  return types[priority] || 'info'
}

function getPriorityLabel(priority) {
  const labels = { high: '高', medium: '中', low: '低' }
  return labels[priority] || '中'
}
</script>

<style scoped>
.box-card {
  max-width: 600px;
  margin: 20px auto;
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 140px);
}

:deep(.el-card__header) {
  position: sticky;
  top: 0;
  z-index: 10;
  background-color: var(--el-bg-color);
  transition: background-color 0.3s;
}

:deep(.el-card__body) {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.card-header {
  display: flex;
  flex-direction: column;
}

.todo-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
  gap: 8px;
}

.todo-item > div:first-child {
  flex: 1;
  min-width: 0;
  overflow: hidden;
}

.todo-item :deep(.el-checkbox__label) {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.todo-actions {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-shrink: 0;
}

.todo-item-wrapper {
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--el-border-color-lighter);
  transition: border-color 0.3s;
}

.todo-item-wrapper:last-child {
  border-bottom: none;
}

.todo-description {
  margin-top: 8px;
  margin-left: 32px;
  padding: 8px 12px;
  background-color: var(--el-fill-color-light);
  border-left: 3px solid var(--el-color-primary);
  border-radius: 4px;
  font-size: 13px;
  color: var(--el-text-color-regular);
  white-space: pre-wrap;
  word-break: break-word;
  transition: background-color 0.3s, color 0.3s;
}

.completed {
  text-decoration: line-through;
  color: var(--el-text-color-disabled);
}

.section-title {
  font-weight: bold;
  color: var(--el-text-color-regular);
  font-size: 14px;
  margin-top: 15px;
  margin-bottom: 10px;
  padding-bottom: 8px;
  border-bottom: 2px solid var(--el-border-color-lighter);
  transition: color 0.3s, border-color 0.3s;
}

.completed-section {
  background-color: var(--el-fill-color-lighter);
  transition: background-color 0.3s;
}

@media (max-width: 600px) {
  .box-card {
    margin: 12px 0;
    border-radius: 8px;
  }

  .todo-actions {
    gap: 4px;
  }

  .todo-actions :deep(.el-button--small) {
    padding: 4px 6px;
    font-size: 12px;
  }

  .todo-actions :deep(.el-button.is-circle) {
    width: 28px;
    height: 28px;
    padding: 6px;
  }

  .todo-description {
    margin-left: 0;
  }

  :deep(.todo-dialog .el-dialog) {
    width: min(600px, 92vw) !important;
    margin: 10vh auto;
  }
}
</style>
