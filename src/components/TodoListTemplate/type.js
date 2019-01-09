// @flow
import type { Todo } from './../TodoList/type'

export type TodoListTemplate = {|
  id: string,
  name: string,
  todos: Array<TodoTemplate>,
|}

export type TodoTemplate = {|
  id: string,
  name: string
|}