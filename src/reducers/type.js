import type { TodoListTemplate } from '../components/TodoListTemplate/type'
import type { Action } from '../actions'
import type {  TodoList } from '../components/TodoList/type';

export type State = {|
  todoListTemplates: Array<TodoListTemplate>,
  todoLists: Array<TodoList>,
  transient: {
    todoListTemplate: TodoListTemplate
  }
|}

export type Dispatch = (action: Action) => any