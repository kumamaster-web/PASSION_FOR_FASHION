import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ["input", "box", "preview", "content"]

  connect() {
    // Auto-connects on every Turbo navigation — no DOMContentLoaded needed
  }

  dragover(event) {
    event.preventDefault()
    this.boxTarget.classList.add("dragover")
  }

  dragleave() {
    this.boxTarget.classList.remove("dragover")
  }

  drop(event) {
    event.preventDefault()
    this.boxTarget.classList.remove("dragover")
    this.inputTarget.files = event.dataTransfer.files
    this.showPreview()
  }

  changed() {
    this.showPreview()
  }

  showPreview() {
    const file = this.inputTarget.files[0]
    if (file && this.hasPreviewTarget) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.hidden = false
        if (this.hasContentTarget) {
          this.contentTarget.hidden = true
        }
      }
      reader.readAsDataURL(file)
    }
  }
}
