import React from 'react'
import TodoListTemplateForm from './form'
import { connect } from 'react-redux'
import { updateTransientTodo, saveChanges } from './../../actions'
import { withRouter } from 'react-router-dom'

type Props = {
  name: string,
  todos: Array<String>
}

function TodoListTemplateCreate ({dispatch, name, todos, history}: Props) {

  function nameChange (name) {
    dispatch(updateTransientTodo({name, todos}))
  }

  function addTodo (title) {
    dispatch(updateTransientTodo(
      {name, todos: [...todos, {title, completed: false, id: 1}]}))
  }

  function commitChanges (data) {
    dispatch(saveChanges(data))
    history.push('/')
  }

  return <div>creation page
    <TodoListTemplateForm onSubmit={commitChanges}
                          onNameChange={nameChange}
                          name={name}
                          todos={todos}
                          onTodoAdd={addTodo}/>
  </div>
}

function mapStateToProps (state) {
  return {
    name: state.transient.todoListTemplate.name,
    todos: state.transient.todoListTemplate.todos,
  }
}

export default withRouter(connect(mapStateToProps)(TodoListTemplateCreate))