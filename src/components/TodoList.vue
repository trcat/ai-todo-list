<template>
  <el-card class="box-card" style="max-width: 600px; margin: 20px auto;">
    <template #header>
      <div class="card-header">
        <span>{{ username }} 的待办事项</span>
        <div style="display: flex; gap: 10px; margin-top: 15px;">
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
    
    <div v-if="todos.length === 0" style="text-align: center; color: #999; padding: 20px;">
      暂无待办事项，快去添加一个吧！
    </div>

    <div v-else>
      <!-- 未完成的任务 -->
      <div v-if="incompleteTodos.length > 0">
        <div class="section-title">进行中 ({{ incompleteTodos.length }})</div>
        <div v-for="todo in incompleteTodos" :key="todo.id" class="todo-item-wrapper">
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
    <el-dialog v-model="showDescriptionDialog" title="编辑描述" width="50%">
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
  </el-card>
</template>

<script>
import { ElMessage } from 'element-plus'

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
      todos: [],
      editingTodo: null,
      showDescriptionDialog: false,
      tempDescription: ''
    }
  },
  computed: {
    incompleteTodos() {
      return this.todos.filter(todo => !todo.completed)
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
        completed: false
      })
      this.newTask = ''
      this.saveTodos()
    },
    removeTask(id) {
      this.todos = this.todos.filter(todo => todo.id !== id)
      this.saveTodos()
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
    saveTodos() {
      localStorage.setItem(`todos_${this.username}`, JSON.stringify(this.todos))
    },
    loadTodos() {
      const saved = localStorage.getItem(`todos_${this.username}`)
      if (saved) {
        try {
          this.todos = JSON.parse(saved)
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
</style>
