// @flow

import {
  COMMIT_TRANSIENT_CHANGES,
  UPDATE_TRANSIENT_TODO,
  GET_FROM_LOCAL,
  EDIT_TEMPLATE,
  RESET_TRANSIENT,
  CLONE_TO_TRANSIENT,
  CREATE_TODO_LIST_FROM_TEMPLATE
} from './constants';
import type { TodoListTemplate } from './components/TodoListTemplate/type'
import type { State } from './reducers/type'

type UpdateTransientTodoAction = {|
  type: typeof UPDATE_TRANSIENT_TODO,
  todoListTemplate: TodoListTemplate
|}

type SaveChangesAction = {|
  type: typeof COMMIT_TRANSIENT_CHANGES
|}

type GetFromLocalAction = {|
  type: typeof GET_FROM_LOCAL,
  state: State,
|}

type EditTemplateAction = {|
  type: typeof EDIT_TEMPLATE,
  templateId: string
|}

type ResetTransient = {
  type: typeof RESET_TRANSIENT
}

type CloneTemplateToTransientAction = {|
  type: typeof CLONE_TO_TRANSIENT,
  templateId: string
|}

type CreateTodoListFromTemplateAction = {|
  type: typeof CREATE_TODO_LIST_FROM_TEMPLATE,
  templateId: string,
  title: string
|}

export type Action =
  | UpdateTransientTodoAction
  | SaveChangesAction
  | GetFromLocalAction
  | EditTemplateAction
  | ResetTransient
  | CloneTemplateToTransientAction

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

export const editTemplate = (templateId: string): EditTemplateAction => {
  return {
    type: EDIT_TEMPLATE,
    templateId,
  }
}

export const resetTransient = {
  type: RESET_TRANSIENT,
}

export const cloneTemplateToTransient = (templateId: string): CloneTemplateToTransientAction => {
  return {
    type: CLONE_TO_TRANSIENT,
    templateId,
  }
}

export const createTodoListFromTemplate = (templateId: string, title: string): CreateTodoListFromTemplateAction => ({
  type: CREATE_TODO_LIST_FROM_TEMPLATE,
  templateId,
  title
})
