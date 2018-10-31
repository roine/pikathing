// @flow

import {
  COMMIT_TRANSIENT_CHANGES,
  UPDATE_TRANSIENT_TODO,
  GET_FROM_LOCAL,
} from './constants'
import type { TodoListTemplate } from './components/TodoListTemplate/type'
import type { State } from './reducers/type'

type UpdateTransientTodoAction = {
  type: typeof UPDATE_TRANSIENT_TODO,
  todoListTemplate: TodoListTemplate
}

type SaveChangesAction = {
  type: typeof COMMIT_TRANSIENT_CHANGES
}

type GetFromLocalAction = {
  type: typeof GET_FROM_LOCAL,
  state: State,
}

export type Action =
  | UpdateTransientTodoAction
  | SaveChangesAction
  | GetFromLocalAction

export const updateTransientTodo = (todoListTemplate: TodoListTemplate): UpdateTransientTodoAction => {
  return {
    type: UPDATE_TRANSIENT_TODO,
    todoListTemplate,
  }
}

export const saveChanges = (): SaveChangesAction => {
  return {
    type: COMMIT_TRANSIENT_CHANGES,
  }
}

export const getFromLocal = (state: any): GetFromLocalAction => {
  return {
    type: GET_FROM_LOCAL,
    state,
  }
}