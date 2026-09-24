# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @templates = [
      { id: 10, name: "Disco Ball", featured: true, emoji: "🪩" },
      { id: 1, name: "Classic", emoji: "⬜" },
      { id: 2, name: "Transparent PNG", emoji: "🔲" },
      { id: 3, name: "Circle Frame", emoji: "⭕" }
    ]
  end
end
