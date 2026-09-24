# frozen_string_literal: true

module QrTemplates
  class Base
    attr_reader :qrcode, :options

    def initialize(qrcode, options = {})
      @qrcode = qrcode
      @options = default_options.merge(options)
    end

    def render_png
      raise NotImplementedError
    end

    private

    def default_options
      {
        foreground: "black",
        background: "white",
        module_size: 10
      }
    end
  end
end
