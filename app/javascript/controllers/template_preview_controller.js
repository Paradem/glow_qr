import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "image", "name"]

  connect() {
    this.update()
  }

  update() {
    const selected = this.optionTargets.find(option => option.checked)
    if (!selected) return

    this.imageTarget.src = selected.dataset.image
    this.nameTarget.textContent = selected.dataset.name
  }
}
