var { Elm } = require('./src/Main.elm')
const key = "app"

const storage = localStorage.getItem(key)
const app = Elm.Main.init({
  node: document.getElementById("elm-node"),
  flags: storage
})

app.ports.save.subscribe(function (data) {
  localStorage.setItem(key, data)
})

window.debug = JSON.parse(localStorage.app)

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
