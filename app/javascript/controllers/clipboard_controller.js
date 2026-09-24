import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.inputTarget.value)
      this.statusTarget.textContent = "Preview link copied!"
    } catch {
      this.inputTarget.focus()
      this.inputTarget.select()
      this.statusTarget.textContent = "Copy isn’t available here. Copy the selected link manually."
    }
  }
}
