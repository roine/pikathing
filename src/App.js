// @flow

import React, { Component } from 'react'
import './App.css'
import { connect } from 'react-redux'
import { BrowserRouter as Router, Link, Route, Switch } from 'react-router-dom'
import Home from './components/Home'
import TodoListTemplateCreate from './components/TodoListTemplate/create'
import { getFromLocal } from './actions'
import { getLocal } from './localStore'
type Props = {
  dispatch: (() => any),
  transient: {
    todoListTemplate: any
  }
}


class App extends Component<Props> {

  componentDidMount () {
    this.props.dispatch(getFromLocal(getLocal()))
  }

  render () {
    return (
      <Router>
        <div className="container">
          <ul>
            <li>
              <Link to="/">Home</Link>
            </li>
            <li>
              <Link to="/todolisttemplate/create">
                Create a todo list template
              </Link>
            </li>
          </ul>
          <Switch>
            <Route exact path="/" component={Home}/>
            <Route path="/todolisttemplate/create"
                   component={TodoListTemplateCreate}/>
          </Switch>
          {JSON.stringify(this.props.transient.todoListTemplate)}
        </div>
      </Router>
    )
  }
}

function mapStateToProps (state) {
  return state
}

export default connect(mapStateToProps)(App)
