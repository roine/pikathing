import type { TodoListTemplate } from '../components/TodoListTemplate/type'
import type { Action } from '../actions'

export type State = {|
  todoListTemplates: Array<TodoListTemplate>,
  transient: {
    todoListTemplate: TodoListTemplate
  }
|}

export type Dispatch = (action: Action) => any