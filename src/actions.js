import {
  COMMIT_TRANSIENT_CHANGES,
  UPDATE_TRANSIENT_TODO,
  GET_FROM_LOCAL,
} from './constants'
import './reducers';


export const updateTransientTodo = (todoListTemplate) => {
  return {
    type: UPDATE_TRANSIENT_TODO,
    todoListTemplate,
  }
}

export const saveChanges = data => {
  return {
    type: COMMIT_TRANSIENT_CHANGES,
  }
}


export const getFromLocal = (state) => {
  return {
    type: GET_FROM_LOCAL,
    state
  }
}