import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import store from './store'
import { Provider } from 'react-redux'
import faker from 'faker'
import puppeteer from 'puppeteer'
import uuidv4 from 'uuid/v4'
import fs from 'fs'

const template = {
  id: uuidv4(),
  title: faker.random.words(),
  todos: [],
}

it('renders without crashing', () => {
  const div = document.createElement('div')
  ReactDOM.render(
    <Provider store={store}>
      <App/>
    </Provider>, div)
  ReactDOM.unmountComponentAtNode(div)
})

let browser, page

beforeAll(async () => {
  browser = await puppeteer.launch()
  page = await browser.newPage()
  await page.setViewport({width: 500, height: 2400})
  console.log = s => {
    process.stdout.write(s + '\n')
  }
})

describe('Home page', () => {

  describe('general behavior', () => {
    beforeEach(async () => {
      await page.goto('http://localhost:3000/')
    })
    test('has a create link', async () => {
      await page.waitForSelector('.navigation__create')
    }, 8000)
  })

  describe('with no data', () => {
    beforeEach(async () => {
      await page.goto('http://localhost:3000/')
    })
    test('shows a no template message if there\'s no template', async () => {
      await page.waitForSelector('.templates__none')
    })
  })

  describe('with data', () => {
    const templatesCount = 2
    beforeEach(async () => {
      await restoreLocalStorage(page, '/fixtures/templates.json')
      await page.goto('http://localhost:3000/')
      await page.waitForSelector('.templates__list')

    })
    test('shows the templates', async () => {
      const itemsCount = await page.$$eval('.templates__list__item',
        items => items.length)
      // Changes if template.json changes
      expect(itemsCount).toBe(templatesCount)
    })
    test('each template has an edit button', async () => {
      const editButtons = await page.$$eval(
        '.templates__list__item .templates__list__item__edit-button',
        lis => lis.length)
      expect(editButtons).toBe(templatesCount)
    })
    test('each template has a show button', async () => {
      const editButtons = await page.$$eval(
        '.templates__list__item .templates__list__item__show-button',
        lis => lis.length)
      expect(editButtons).toBe(templatesCount)
    })
  })
})

afterAll(() => {
  browser.close()
})

async function restoreLocalStorage (page, filePath) {
  const json = JSON.parse(
    fs.readFileSync(`${__dirname}/../${filePath}`, 'utf8'))

  await page.evaluate(json => {
    localStorage.clear()
    for (let key in json)
      localStorage.setItem(key, JSON.stringify(json[key]))
  }, json)
}