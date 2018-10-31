// @flow
import React from 'react'
import type { TodoListTemplate } from './type'

type Props = {
  onSubmit: (void => void),
  todoListTemplate: TodoListTemplate,
  onNameChange: string => void,
  onTodoAdd: string => void
}

function TodoListTemplateForm ({onSubmit, todoListTemplate, onNameChange, onTodoAdd}: Props) {

  let todoText: ?HTMLInputElement

  const {name} = todoListTemplate

  function addTodo () {
    if (todoText) {
      onTodoAdd(todoText.value)
      todoText.value = ''
    }
    else {
      alert('todo element not found')
    }
  }

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      onSubmit()
    }}>
      <div className="form-group">
        <label htmlFor="name">Name</label>
        <input className="form-control" placeholder="House Buying" type="text"
               value={name} onChange={(ev) => onNameChange(ev.target.value)}/>
      </div>
      <div className="form-group">
        <label htmlFor="todo">Todo</label>
        <input type="text" className="form-control"
               ref={node => todoText = node}/>
      </div>
      <button type="button" onClick={addTodo}>Add Todo
      </button>
      <button type="submit">Save and Exit</button>
    </form>
  )
}

export default TodoListTemplateForm