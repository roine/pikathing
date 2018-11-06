// @flow
import React from 'react'
import type { TodoListTemplate } from './type'

type Props = {
  onSubmit: void => void,
  todoListTemplate: TodoListTemplate,
  onNameChange: string => void,
  onTodoAdd: string => void,
  className: string
}

function TodoListTemplateForm ({onSubmit, todoListTemplate, onNameChange, onTodoAdd, className}: Props) {

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
    }} className={className}>
      <div className="form-group">
        <label htmlFor="name">Name</label>
        <input className="form-control" placeholder="House Buying" type="text"
               value={name} onChange={(ev) => onNameChange(ev.target.value)}
               name="name"/>
      </div>
      <div className="form-group">
        <label htmlFor="todo">Todo</label>
        <input type="text" className="form-control"
               ref={node => todoText = node}
               name="todo"/>
      </div>
      <button type="button" onClick={addTodo}>Add Todo
      </button>
      <ul>{todoListTemplate.todos.map(
        (todo, idx) => <li key={idx}>{todo.title} - {todo.id}</li>)}</ul>
      <button type="submit">Save and Exit</button>
    </form>
  )
}

export default TodoListTemplateForm