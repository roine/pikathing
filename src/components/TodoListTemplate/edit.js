import React from 'react'
import TodoListTemplateForm from './form'
import { connect } from 'react-redux'
import {
  cloneTemplateToTransient,
  resetTransient,
  saveChanges,
  updateTransientTodo,
} from '../../actions'
import uuidv4 from 'uuid/v4'

class Edit extends React.Component<Props> {

  componentDidMount () {
    this.props.dispatch(cloneTemplateToTransient(this.props.match.params.id))
  }

  componentWillUnmount () {
    this.props.dispatch(resetTransient)
  }

  nameChange = (name) => {
    this.props.dispatch(
      updateTransientTodo({...this.props.todoListTemplate, name}))
  }

  addTodo = (title) => {
    const {id, name, todos} = this.props.todoListTemplate
    this.props.dispatch(updateTransientTodo(
      {id, name, todos: [...todos, {title, completed: false, id: uuidv4()}]}))
  }

  commitChanges = () => {
    this.props.dispatch(saveChanges())
    this.props.history.push('/')
  }

  render () {

    if (!this.props.todoListTemplate) {
      return <div>loading</div>
    }

    return (
      <div>
        <TodoListTemplateForm onSubmit={this.commitChanges}
                              todoListTemplate={this.props.todoListTemplate}
                              onNameChange={this.nameChange}
                              onTodoAdd={this.addTodo}
                              className="form-edit"/>
      </div>
    )

  }
}

function mapStateToProps (state) {
  return {
    todoListTemplate: state.transient.todoListTemplate,
  }
}

export default connect(mapStateToProps)(Edit)