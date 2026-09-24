# frozen_string_literal: true

module QrCodesHelper
  def qr_template_options
    [
      { id: 1, name: "Classic", description: "Clean & timeless" },
      { id: 2, name: "Transparent PNG", description: "Made for layering" },
      { id: 3, name: "Circle Frame", description: "A softer shape" },
      { id: 10, name: "Disco Ball", description: "A little extra sparkle" }
    ]
  end
end
