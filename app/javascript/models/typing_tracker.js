const REFRESH_INTERVAL = 1000
const TYPING_TIMEOUT = 5000

export default class TypingTracker {
  constructor(callback) {
    this.callback = callback
    this.currentlyTyping = {}
    this.timer = setInterval(this.#refresh.bind(this), REFRESH_INTERVAL)
  }

  close() {
    clearInterval(this.timer)
  }

  add(name) {
    this.currentlyTyping[name] = Date.now()
    this.#refresh()
  }

  remove(name) {
    delete this.currentlyTyping[name]
    this.#refresh()
  }

  #refresh() {
    this.#purgeInactive()
    const names = Object.keys(this.currentlyTyping).sort()

    if (names.length > 0) {
      this.callback(`${names.join(", ")}`)
    } else {
      this.callback(null)
    }
  }

  #purgeInactive() {
    const cutoff = Date.now() - TYPING_TIMEOUT
    this.currentlyTyping = Object.fromEntries(
      Object.entries(this.currentlyTyping).filter(([_name, timestamp]) => timestamp > cutoff)
   )
  }
}
