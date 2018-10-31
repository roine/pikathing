// @flow

export type TodoListTemplate = {
  id: string,
  name: string,
  todos: Array<Todo>,
}

export type Todo = {
  id: string,
  title: string,
  completed: boolean,
}