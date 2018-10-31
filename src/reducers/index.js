import {
  COMMIT_TRANSIENT_CHANGES,
  GET_FROM_LOCAL,
  UPDATE_TRANSIENT_TODO,
} from '../constants'
import uuidv4 from 'uuid/v4'

type Todo = {
  id: number,
  title: string,
  completed: boolean,
}

type TodoListTemplate = {
  id: number,
  name: string,
  todos: Array<Todo>,
}

const initialTemplate: TodoListTemplate = {
  name: 'House',
  todos: [{id: uuidv4(), title: '3 beds or more', completed: false}],
}

type State = {
  todoListTemplates: Array<TodoListTemplate>,
  transient: {
    todoListTemplate: TodoListTemplate
  }
}

const initialTransientTemplate = {name: '', todos: []}

const initialState = {
  todoListTemplates: [initialTemplate],
  transient: {
    todoListTemplate: initialTransientTemplate,
  },
}

function reducer (state: State = initialState, action) {
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
          {...state.transient.todoListTemplate, id: uuidv4()},
        ],
        transient: {
          ...state.transient,
          todoListTemplate: initialTransientTemplate,
        },
      }
    case GET_FROM_LOCAL:
      return action.state
    default:
      return state
  }
}

export default reducer