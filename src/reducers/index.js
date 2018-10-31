// @flow

import {
  COMMIT_TRANSIENT_CHANGES,
  GET_FROM_LOCAL,
  UPDATE_TRANSIENT_TODO,
} from '../constants'
import uuidv4 from 'uuid/v4'
import type { TodoListTemplate } from './../components/TodoListTemplate/type'
import type { Action } from './../actions'
import type { State } from './type'

const initialTemplate: TodoListTemplate = {
  id: uuidv4(),
  name: 'House',
  todos: [
    {
      id: uuidv4(),
      title: '3 beds or more',
      completed: false,
    }],
}

const initialTransientTemplate: TodoListTemplate = {
  id: uuidv4(),
  name: '',
  todos: [],
}

const initialState: State = {
  todoListTemplates: [initialTemplate],
  transient: {
    todoListTemplate: initialTransientTemplate,
  },
}

function reducer (state: State = initialState, action: Action): State {
  switch (action.type) {
    case UPDATE_TRANSIENT_TODO:
      return {
        ...state,
        transient: {
          ...state.transient,
          todoListTemplate: action.todoListTemplate,
        },
      }
    case COMMIT_TRANSIENT_CHANGES:
      return {
        ...state,
        todoListTemplates: [
          ...state.todoListTemplates,
          {...state.transient.todoListTemplate},
        ],
        transient: {
          ...state.transient,
          todoListTemplate: initialTransientTemplate,
        },
      }
    case GET_FROM_LOCAL:
      if (action.state) {
        return action.state
      }
      return state
    default:
      return state
  }
}

export default reducer