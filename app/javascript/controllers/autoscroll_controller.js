import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Autoscroll controller connected")
    this.scrollToBottom()
    this.setupMutationObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  // Called when new content is added via Turbo Stream
  messageAdded() {
    console.log("Message added, scrolling...")
    this.scrollToBottom()
  }

  setupMutationObserver() {
    // Watch for changes in the message history (including streaming updates)
    this.observer = new MutationObserver(() => {
      console.log("DOM changed, scrolling...")
      this.scrollToBottom()
    })

    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
      characterData: true
    })
  }

  scrollToBottom() {
    console.log(`Scrolling to bottom. scrollHeight: ${this.element.scrollHeight}`)
    // Use both methods to ensure scrolling works
    this.element.scrollTop = this.element.scrollHeight
    
    // Also try smooth scrolling as backup
    setTimeout(() => {
      this.element.scrollTo({
        top: this.element.scrollHeight,
        behavior: 'smooth'
      })
    }, 10)
  }
}