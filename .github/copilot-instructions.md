# Copilot Instructions for hello-vue

## Project Overview
A Vue 3 todo application with user authentication. Uses Element Plus UI components and localStorage for persistence. Authentication is client-side only; login validation occurs in LoginModal with username/password both required.

## Architecture

### Component Structure
- **App.vue**: Root component managing auth state and layout. Shows LoginModal if unauthenticated, TodoList if authenticated
- **LoginModal.vue**: Controlled via v-model, emits login event with `{username, password}` object
- **TodoList.vue**: Per-user todo management, receives `username` prop, manages separate localStorage key per user

### Data Flow
- User login → stored in localStorage as `currentUser`
- Todos → stored per-user as `todos_{username}` in localStorage (each todo has `{id, text, description, completed}`)
- No backend; all state client-side
- Service Worker handles offline caching with network-first strategy

### PWA Support
- **Manifest**: `public/manifest.json` defines app metadata, icons, theme color (#409EFF)
- **Service Worker**: `public/service-worker.js` caches static assets and enables offline functionality
- **Registration**: Automatic via `main.js` on page load
- Users can install app via browser's "Install app" prompt or settings menu

## Key Patterns & Conventions

### Vue 3 Composition
- Uses Options API (not Composition API) with `data()`, `computed`, `methods`
- v-model binding: `LoginModal` uses getter/setter computed property to emit `update:modelValue`
- Component props are explicit; TodoList requires `username` string prop

### State Management
- localStorage keys follow pattern: `currentUser` (logged-in user), `todos_{username}` (tasks)
- No validation on localStorage retrieval; wrapped in try-catch in TodoList.loadTodos()
- User data reset to empty string on logout

### UI Library (Element Plus)
- Icons from `@element-plus/icons-vue` auto-registered in main.js
- Use `el-card`, `el-dialog`, `el-button`, `el-input`, `el-checkbox`, `el-empty`, `el-container`/`el-header`/`el-main`
- Style scoped scopes to avoid conflicts

### Form Handling
- LoginModal validates both fields present before emit
- TodoList adds tasks on Enter key or button click
- Input clearing handled immediately after action

## Build & Development

```bash
npm install        # Install dependencies
npm run serve      # Dev server on http://localhost:8080 (hot reload enabled)
npm run build      # Production build to dist/
npm run lint       # Run ESLint with Vue plugin (vue3-essential config)
```

## GitHub Pages Deployment

The project is configured for automatic deployment to GitHub Pages:
- **Workflow**: `.github/workflows/deploy.yml`
- **Trigger**: Automatic on push to `main` branch
- **Build Process**: 
  1. Installs dependencies with `npm install`
  2. Builds project with `npm run build`
  3. Deploys `dist/` directory to GitHub Pages
- **Base URL**: `https://trcat.github.io/ai-todo-list/`
- **Configuration**: `vue.config.js` sets correct `publicPath` for production

To enable GitHub Pages:
1. Go to repository Settings → Pages
2. Select "GitHub Actions" as the deployment source
3. Push to main branch to trigger automatic deployment

## File Locations
- Components: `src/components/`
- Main app: `src/App.vue`, `src/main.js`
- Config: `babel.config.js` (empty), `vue.config.js` (default)
- UI styles: Element Plus CSS imported in main.js

## Common Tasks

### Adding a New Feature
1. If it's a user-specific feature, pass `username` prop through TodoList
2. Store new per-user data as `feature_{username}` in localStorage
3. Add Element Plus component import if using new UI elements
4. No state management setup needed; use component data()

### Fixing a Bug
- Check localStorage format (todos are arrays of `{id, text, completed}`)
- Verify v-model binding in modals (uses getter/setter pattern)
- Remember user data is reset on logout—don't assume persistence across sessions

### Styling
- Global styles in App.vue `<style>` block
- Component styles use `<style scoped>` to avoid cascading
- Color scheme: blue (#409EFF), light gray (#f5f7fa, #f0f0f0)
