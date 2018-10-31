// @flow

import React from 'react'
import TodoListTemplateForm from './form'
import { connect } from 'react-redux'
import { updateTransientTodo, saveChanges } from './../../actions'
import { withRouter } from 'react-router-dom'
import uuidv4 from 'uuid/v4'
import type { Dispatch } from '../../reducers/type'
import type { TodoListTemplate } from './type'

type Props = {
  todoListTemplate: TodoListTemplate,
  dispatch: Dispatch,
  history: any
}

function TodoListTemplateCreate ({dispatch, todoListTemplate, history}: Props) {

  const {todos, id, name} = todoListTemplate

  function nameChange (name) {
    dispatch(updateTransientTodo({...todoListTemplate, name}))
  }

  function addTodo (title) {
    dispatch(updateTransientTodo(
      {id, name, todos: [...todos, {title, completed: false, id: uuidv4()}]}))
  }

  function commitChanges () {
    dispatch(saveChanges())
    history.push('/')
  }

  return <div>creation page
    <TodoListTemplateForm onSubmit={commitChanges}
                          onNameChange={nameChange}
                          todoListTemplate={todoListTemplate}
                          onTodoAdd={addTodo}/>
  </div>
}

function mapStateToProps (state) {
  return {
    todoListTemplate: state.transient.todoListTemplate,
  }
}

export default withRouter(connect(mapStateToProps)(TodoListTemplateCreate))