import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    this.element.addEventListener("dragover", this.dragOver.bind(this))
    this.element.addEventListener("dragleave", this.dragLeave.bind(this))
    this.element.addEventListener("drop", this.drop.bind(this))
  }

  dragOver(event) {
    event.preventDefault()
    this.element.classList.add("drop-zone--over")
  }

  dragLeave(event) {
    event.preventDefault()
    this.element.classList.remove("drop-zone--over")
  }

  drop(event) {
    event.preventDefault()
    this.element.classList.remove("drop-zone--over")

    if (event.dataTransfer.files.length > 0) {
      this.inputTarget.files = event.dataTransfer.files
      this.element.closest("form").submit()
    }
  }

  // ファイル選択（クリック）時にも自動送信
  submitForm() {
    this.element.closest("form").submit()
  }
}
