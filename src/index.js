import './style/main.scss';
import { Elm } from './Main.elm';
import Parse from 'parse';
import registerServiceWorker from './registerServiceWorker';
const key = "app"
const storage = localStorage.getItem(key)

const app = Elm.Main.init({
  node: document.getElementById("elm-node"),
  flags: storage
})

app.ports.save.subscribe(function (data) {
  localStorage.setItem(key, data)
})

app.ports.export_.subscribe(function () {
  const data = localStorage.getItem(key)
  var dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(data)
  var downloadAnchorNode = document.createElement('a')
  downloadAnchorNode.setAttribute("href", dataStr)
  downloadAnchorNode.setAttribute("download", "backup.json")
  document.body.appendChild(downloadAnchorNode) // required for firefox
  downloadAnchorNode.click()
  downloadAnchorNode.remove()
})



Parse.serverURL = 'https://parseapi.back4app.com'; // This is your Server URL
Parse.initialize(
  'oTuSAtv9yh58v9DBFn6ihsLTvZcKbZ6eXALveQmJ', // This is your Application ID
  'IUYaPjErpMw0JPLJdn0hiim2x06kl6C8jA1dQWRw', // This is your Javascript key
);
const MyCustomClass = Parse.Object.extend('roine');
const myNewObject = new MyCustomClass();

myNewObject.set('todoTemplates', 'myCustomKey1Value');
myNewObject.set('todos', 'myCustomKey2Value');
myNewObject.set('todoListTemplates', 'myCustomKey2Value');
myNewObject.set('todoLists', 'myCustomKey2Value');
myNewObject.save()
registerServiceWorker();

