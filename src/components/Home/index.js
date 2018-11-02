// @flow

import React from 'react'
import { connect } from 'react-redux'
import type { Dispatch, State } from '../../reducers/type'
import type { TodoListTemplate } from '../TodoListTemplate/type'
import { editTemplate } from '../../actions'
import { withRouter } from 'react-router-dom'

type Props = {
  todoListTemplates: Array<TodoListTemplate>,
  dispatch: Dispatch,
  history: any
}

function Home (props: Props) {

  function edit (templateId: string) {
    props.dispatch(editTemplate(templateId))
    props.history.push(`/todolisttemplate/edit/${templateId}`)
  }

  const noTemplateView = <div>There is no template yet.</div>

  function templateListView (todoTemplates) {

    return <div>Here's a list of available templates
      {todoTemplates.map(singleTemplateView)}</div>
  }

  function singleTemplateView (template: TodoListTemplate, idx: number) {
    return (
      <div key={idx}>
        {template.name} - {template.id}
        <button onClick={() => edit(template.id)}>Edit</button>
      </div>
    )
  }

  return (
    <div>
      {props.todoListTemplates.length ?
        templateListView(props.todoListTemplates) :
        noTemplateView
      }
    </div>)
}

function mapStateToProps (state: State) {
  return {
    todoListTemplates: state.todoListTemplates,
  }
}

export default withRouter(connect(mapStateToProps)(Home))