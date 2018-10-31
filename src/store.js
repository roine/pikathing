import { createStore } from 'redux'
import reducers from './reducers'
import { saveLocal } from './localStore'
import throttle from 'lodash/throttle'

const store = createStore(reducers)

store.subscribe(throttle(() => saveLocal(store.getState()), 800))

export default store