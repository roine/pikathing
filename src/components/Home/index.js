import React from 'react';
import { connect } from 'react-redux';

function Home (props) {

  const noTemplateView = <div>There is no template yet.</div>;

  function templateListView (todoTemplates) {
    return <div>Here's a list of available templates
      {todoTemplates.map(singleTemplateView)}</div>;
  }

  function singleTemplateView(template, idx) {
    return <div key={idx}>{template.name} - {template.id}</div>
  }

  return (
    <div>
      {props.todoListTemplates.length ?  templateListView(props.todoListTemplates): noTemplateView}
    </div>);
}

function mapStateToProps (state) {
  return {
    todoListTemplates: state.todoListTemplates,
  };
}

export default connect(mapStateToProps)(Home);