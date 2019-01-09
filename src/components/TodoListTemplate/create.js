// @flow

import React from 'react'
import TodoListTemplateForm from './form'
import { connect } from 'react-redux'
import { updateTransientTodo, saveChanges } from './../../actions'
import { withRouter } from 'react-router-dom'
import uuidv4 from 'uuid/v4'
import type { Dispatch } from '../../reducers/type'
import type { TodoListTemplate } from './type'
import { resetTransient } from '../../actions'

type Props = {
  todoListTemplate: TodoListTemplate,
  dispatch: Dispatch,
  history: any
}

class Create extends React.Component<Props> {

  componentWillUnmount () {
    this.props.dispatch(resetTransient)
  }

  nameChange = (name) => {
    this.props.dispatch(
      updateTransientTodo({...this.props.todoListTemplate, name}))
  }

  addTodo = (name) => {
    const {id, todos} = this.props.todoListTemplate
    this.props.dispatch(updateTransientTodo(
      {
        id,
        name: this.props.todoListTemplate.name,
        todos: [...todos, {name, id: uuidv4()}],
      }))
  }

  commitChanges = () => {
    this.props.dispatch(saveChanges())
    this.props.history.push('/')
  }

  render () {
    return (
      <div>creation page
        <TodoListTemplateForm onSubmit={this.commitChanges}
                              todoListTemplate={this.props.todoListTemplate}
                              onNameChange={this.nameChange}
                              onTodoAdd={this.addTodo}
        className="form-create"/>
      </div>)
  }
}

function mapStateToProps (state) {
  return {
    todoListTemplate: state.transient.todoListTemplate,
  }
}

export default withRouter(connect(mapStateToProps)(Create))