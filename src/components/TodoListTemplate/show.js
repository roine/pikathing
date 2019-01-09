import React from 'react';
import { Redirect, withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import { createTodoListFromTemplate } from '../../actions';

let input;

function Show ({match, template, todoLists, dispatch}: Props) {
  function createTodoList () {
    if(input && input.value) {
      dispatch(createTodoListFromTemplate(template.id, input.value));
      input.value = ''
    }
  }

  if (!template) {
    return <Redirect
      to={{pathname: '/', state: {alert: 'Template not found'}}}/>;
  }

  return (
    <div>
      <input type="text" ref={node => input = node}/>
      <button onClick={createTodoList}>
        Create a new todo using {template.name} template
      </button>
      <ul>
        {todoLists.map(todoList =>
          <li key={todoList.id}>{todoList.title}</li>
        )}
      </ul>
    </div>
  );
}

function mapStateToProps (state, props) {
  const currentTemplateId = props.match.params.id;
  console.log(state)
  return {
    template: state.todoListTemplates.find(template =>
      template.id === currentTemplateId),
    todoLists: state.todoLists.filter(
      todoList => todoList.templateId === currentTemplateId)
  };
}

export default connect(mapStateToProps)(withRouter(Show));