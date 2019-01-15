var { Elm } = require('./src/Main.elm')
const key = "app"

const storage = localStorage.getItem(key)
const app = Elm.Main.init({
  node: document.getElementById("elm-node"),
  flags: storage
})

app.ports.save.subscribe(function (e) {
  localStorage.setItem(key, e)
})