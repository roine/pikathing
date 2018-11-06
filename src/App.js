// @flow

import React, { Component } from 'react'
import './App.css'
import { connect } from 'react-redux'
import { BrowserRouter as Router, Link, Route, Switch } from 'react-router-dom'
import Home from './components/Home'
import TodoListTemplateCreate from './components/TodoListTemplate/create'
import TodoListTemplateEdit from './components/TodoListTemplate/edit'
import TodoListTemplateShow from './components/TodoListTemplate/show'
import { getFromLocal } from './actions'
import { getLocal } from './localStore'
import type { TodoListTemplate } from './components/TodoListTemplate/type'
import type { Dispatch } from './reducers/type'

type Props = {
  dispatch: Dispatch,
  transient: {
    todoListTemplate: TodoListTemplate
  }
}

class App extends Component<Props> {
  constructor (props) {
    super(props)
    this.props.dispatch(getFromLocal(getLocal()))
  }

  render () {
    return (
      <Router>
        <div className="container">
          <ul className="navigation">
            <li>
              <Link to="/">Home</Link>
            </li>
            <li>
              <Link className="navigation__create"
                    to="/todolisttemplate/create">
                Create a todo list template
              </Link>
            </li>
          </ul>
          <Switch>
            <Route exact path="/" component={Home}/>
            <Route path="/todolisttemplate/create"
                   component={TodoListTemplateCreate}/>
            <Route path="/todolisttemplate/edit/:id"
                   component={TodoListTemplateEdit}/>
            <Route path="/todolisttemplate/show/:id"
                   component={TodoListTemplateShow}/>
          </Switch>
          {JSON.stringify(this.props.transient)}
        </div>
      </Router>
    )
  }
}

function mapStateToProps (state) {
  return state
}

export default connect(mapStateToProps)(App)
