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

  function show (templateId: string) {
    props.history.push(`todolisttemplate/show/${templateId}`)
  }

  const noTemplateView = (
    <div className="templates__none">
      There is no template yet.
    </div>
  )

  function templateListView (todoTemplates) {
    return (
      <ul className="templates__list">
        {todoTemplates.map(singleTemplateView)}
      </ul>
    )
  }

  function singleTemplateView (template: TodoListTemplate, idx: number) {
    return (
      <li key={idx} className="templates__list__item">
        {template.name} - {template.id}
        <button onClick={() => edit(template.id)}
                className="templates__list__item__edit-button">Edit
        </button>
        <button onClick={() => show(template.id)}
                className="templates__list__item__show-button">Show
        </button>
      </li>
    )
  }

  return (
    <div className="templates">
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