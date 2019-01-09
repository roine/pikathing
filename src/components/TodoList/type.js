// @flow

export type Todo = {|
  id: string,
  templateId: string,
  completed: boolean,
|}

export type TodoList = {|
  id: string,
  templateId: string,
  title: string,
  todos: Array<Todo>
|}
