<template>
  <el-card class="box-card">
    <template #header>
      <div class="card-header">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span>{{ username }} 的待办事项</span>
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
        <div style="display: flex; gap: 10px; margin-top: 15px;">
          <el-select v-model="newTaskPriority" placeholder="优先级" style="width: 100px;">
            <el-option label="低" value="low" />
            <el-option label="中" value="medium" />
            <el-option label="高" value="high" />
          </el-select>
          <el-input
            v-model="newTask"
            placeholder="请输入待办事项..."
            @keyup.enter="addTask"
          >
            <template #append>
              <el-button @click="addTask">添加</el-button>
            </template>
          </el-input>
        </div>
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
              <el-checkbox v-model="todo.completed" @change="saveTodos">
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
            <el-checkbox v-model="todo.completed" @change="saveTodos">
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

<script>
import { ElMessage, ElMessageBox } from 'element-plus'

export default {
  name: 'TodoList',
  props: {
    username: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      newTask: '',
      newTaskPriority: 'medium',
      todos: [],
      editingTodo: null,
      showDescriptionDialog: false,
      tempDescription: '',
      showPriorityDialog: false,
      tempPriority: 'medium'
    }
  },
  computed: {
    incompleteTodos() {
      const priorityOrder = { high: 1, medium: 2, low: 3 }
      return this.todos
        .filter(todo => !todo.completed)
        .sort((a, b) => priorityOrder[a.priority || 'medium'] - priorityOrder[b.priority || 'medium'])
    },
    completedTodos() {
      return this.todos.filter(todo => todo.completed)
    }
  },
  mounted() {
    this.loadTodos()
  },
  methods: {
    addTask() {
      if (!this.newTask.trim()) {
        ElMessage.warning('请输入内容')
        return
      }
      this.todos.push({
        id: Date.now(),
        text: this.newTask,
        description: '',
        priority: this.newTaskPriority,
        completed: false
      })
      this.newTask = ''
      this.newTaskPriority = 'medium'
      this.saveTodos()
    },
    removeTask(id) {
      ElMessageBox.confirm(
        '确定要删除这个待办事项吗？',
        '删除确认',
        {
          confirmButtonText: '删除',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(() => {
        this.todos = this.todos.filter(todo => todo.id !== id)
        this.saveTodos()
        ElMessage.success('已删除')
      }).catch(() => {})
    },
    openDescriptionDialog(todo) {
      this.editingTodo = todo
      this.tempDescription = todo.description || ''
      this.showDescriptionDialog = true
    },
    saveDescription() {
      if (this.editingTodo) {
        this.editingTodo.description = this.tempDescription
        this.saveTodos()
        this.showDescriptionDialog = false
        ElMessage.success('描述已保存')
      }
    },
    openPriorityDialog(todo) {
      this.editingTodo = todo
      this.tempPriority = todo.priority || 'medium'
      this.showPriorityDialog = true
    },
    savePriority() {
      if (this.editingTodo) {
        this.editingTodo.priority = this.tempPriority
        this.saveTodos()
        this.showPriorityDialog = false
        ElMessage.success('优先级已更新')
      }
    },
    clearCompleted() {
      const count = this.completedTodos.length
      this.todos = this.todos.filter(todo => !todo.completed)
      this.saveTodos()
      ElMessage.success(`已清除 ${count} 个已完成任务`)
    },
    getPriorityType(priority) {
      const types = { high: 'danger', medium: 'warning', low: 'info' }
      return types[priority] || 'info'
    },
    getPriorityLabel(priority) {
      const labels = { high: '高', medium: '中', low: '低' }
      return labels[priority] || '中'
    },
    saveTodos() {
      localStorage.setItem(`todos_${this.username}`, JSON.stringify(this.todos))
    },
    loadTodos() {
      const saved = localStorage.getItem(`todos_${this.username}`)
      if (saved) {
        try {
          this.todos = JSON.parse(saved).map(todo => ({
            ...todo,
            priority: todo.priority || 'medium'
          }))
        } catch (e) {
          this.todos = []
        }
      } else {
        this.todos = []
      }
    }
  }
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
  background-color: #fff;
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
}

.todo-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.todo-item-wrapper {
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.todo-item-wrapper:last-child {
  border-bottom: none;
}

.todo-description {
  margin-top: 8px;
  margin-left: 32px;
  padding: 8px 12px;
  background-color: #f5f7fa;
  border-left: 3px solid #409EFF;
  border-radius: 4px;
  font-size: 13px;
  color: #606266;
  white-space: pre-wrap;
  word-break: break-word;
}

.completed {
  text-decoration: line-through;
  color: #ccc;
}

.section-title {
  font-weight: bold;
  color: #606266;
  font-size: 14px;
  margin-top: 15px;
  margin-bottom: 10px;
  padding-bottom: 8px;
  border-bottom: 2px solid #f0f0f0;
}

.completed-section {
  background-color: #fafafa;
}

@media (max-width: 600px) {
  .box-card {
    margin: 12px 0;
    border-radius: 8px;
  }

  .todo-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .todo-actions {
    width: 100%;
    justify-content: flex-end;
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
