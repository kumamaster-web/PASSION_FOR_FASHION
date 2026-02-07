import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="inline-chat"
// Manages the inline chat panel on the results page
export default class extends Controller {
  static targets = ["panel", "toggle", "messages"]

  connect() {
    // Observe mutations on the messages div to auto-scroll when new messages arrive
    this.observer = new MutationObserver(() => this.scrollToBottom())
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  // When the panel target appears (chat loaded via Turbo Stream)
  panelTargetConnected() {
    this.scrollToBottom()
  }

  // When the messages target connects, start observing for new children
  messagesTargetConnected() {
    this.observer.observe(this.messagesTarget, { childList: true })
    this.scrollToBottom()
  }

  messagesTargetDisconnected() {
    if (this.observer) this.observer.disconnect()
  }

  toggle() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.toggle("d-none")
      this.scrollToBottom()
    }
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }
}
