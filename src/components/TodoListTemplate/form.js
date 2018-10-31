import React from 'react'

function TodoListTemplateForm ({onSubmit, name, todos, onNameChange, onTodoAdd}) {

  let todoText

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      onSubmit({name, todos})
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
      <button type="button" onClick={() => {
        onTodoAdd(todoText.value)
        todoText.value = ''
      }}>Add Todo
      </button>
      <button type="submit">Save and Exit</button>
    </form>
  )
}

export default TodoListTemplateForm