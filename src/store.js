import { createStore } from 'redux';
import reducers from './reducers';
import { saveLocal } from './localStore';
import throttle from 'lodash/throttle';

const store = createStore(reducers);

store.subscribe(throttle(() => saveLocal({
  todoListTemplates: store.getState().todoListTemplates,
  todoLists: store.getState().todoLists
}), 800));

export default store;