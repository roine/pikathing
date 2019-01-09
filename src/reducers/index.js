// @flow

import {
  CLONE_TO_TRANSIENT,
  COMMIT_TRANSIENT_CHANGES, CREATE_TODO_LIST_FROM_TEMPLATE, EDIT_TEMPLATE,
  GET_FROM_LOCAL, RESET_TRANSIENT,
  UPDATE_TRANSIENT_TODO
} from '../constants';
import uuidv4 from 'uuid/v4';
import type { TodoListTemplate } from './../components/TodoListTemplate/type';
import type { Action } from './../actions';
import type { State } from './type';
import Dict from '@roine/dict';

const initialTransientTemplate = (): TodoListTemplate => {
  return {
    id: uuidv4(),
    name: '',
    todos: []
  };
};

const initialState: State = {
  todoListTemplates: [],
  todoLists: [],
  transient: {
    todoListTemplate: initialTransientTemplate()
  }
};

function reducer (state: State = initialState, action: Action): State {
  console.log(action);
  switch (action.type) {
    case UPDATE_TRANSIENT_TODO:
      return {
        ...state,
        transient: {
          ...state.transient,
          todoListTemplate: action.todoListTemplate
        }
      };
    case COMMIT_TRANSIENT_CHANGES:
      const dict = new Dict();
      // replace if exist otherwise push
      const newTodoListTemplates = dict.insert(state.transient.todoListTemplate,
        state.todoListTemplates);
      return {
        ...state,
        todoListTemplates: newTodoListTemplates,
        transient: {
          ...state.transient,
          todoListTemplate: initialTransientTemplate()
        }
      };
    case GET_FROM_LOCAL:
      if (action.state) {
        return {
          ...state,
          todoListTemplates: action.state.todoListTemplates,
          todoLists: action.state.todoLists
        };
      }
      return state;
    case EDIT_TEMPLATE:
      const template = state.todoListTemplates.find(
        tem => tem.id === action.templateId);
      if (!template) {
        return state;
      }
      return {
        ...state,
        transient: {
          ...state.transient,
          todoListTemplate: template
        }
      };
    case RESET_TRANSIENT:
      return {
        ...state,
        transient: {
          ...state.transient,
          todoListTemplate: initialTransientTemplate()
        }
      };
    case CLONE_TO_TRANSIENT:
      let todoTemplate = state.todoListTemplates.find(
        t => t.id === action.templateId);
      return {
        ...state,
        transient: {...state.transient, todoListTemplate: todoTemplate}
      };
    case CREATE_TODO_LIST_FROM_TEMPLATE: {
      let todoTemplate = state.todoListTemplates.find(
        t => t.id === action.templateId);
      const todoList = {
        id: uuidv4(),
        templateId: todoTemplate.id,
        todos: todoTemplate.todos,
        title: action.title
      };
      return {
        ...state,
        todoLists: [...state.todoLists, todoList]
      };
    }
    default:
      return state;
  }
}

export default reducer;