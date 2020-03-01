require 'paleta/core_ext/math'

module Paleta
  # Represents a color
  class Color
    include Math

    attr_reader :red, :green, :blue, :hue, :saturation, :lightness, :hex

    # Initailize a {Color}
    #
    # @overload initialize()
    #   Initialize a {Color} to black
    #
    # @overload initialize(color)
    #   Initialize a {Color} from a {Color}
    #   @param [Color] color a color to copy
    #
    # @overload initialize(model, value)
    #   Initialize a {Color} with a hex value
    #   @param [Symbol] model the color model, should be :hex in this case
    #   @param [String] value a 6 character hexadecimal string
    #
    # @overload initialize(model, value, value, value)
    #   Initialize a {Color} with HSL or RGB component values
    #   @param [Symbol] model the color model, should be :hsl or :rgb
    #   @param [Number] (red,hue) the red or hue component value, depending on the value of model
    #   @param [Number] (green,saturation) the green or saturation component value
    #   @param [Number] (blue,lightness) the blue or lightness component value
    #
    # @overload initialize(value, value, value)
    #   Initialize a {Color} with RGB component values
    #   @param [Number] red the red component value
    #   @param [Number] green the green component value
    #   @param [Number] blue the blue component value
    #
    # @return [Color] A new instance of {Color}
    def initialize(*args)
      if args.length == 1 && args[0].is_a?(Color)
        args[0].instance_variables.each do |key|
          self.send("#{key[1..key.length]}=".to_sym, args[0].send("#{key[1..key.length]}"))
        end
      elsif args.length == 2 && args[0] == :hex && args[1].is_a?(String)
        # example: new(:hex, "336699")
        # example: new(:hex, "#336699")
        # example: new(:hex, "#fff")
        color_hex = args[1]
        color_hex = color_hex[1..-1] if color_hex.start_with?('#')

        # These are all string operations to make a "fea" into a "ffeeaa"
        color_hex = color_hex[0] * 2 + color_hex[1] * 2 + color_hex[2] * 2 if color_hex.length == 3

        hex_init(color_hex)
      elsif args.length == 3 && args[0].is_a?(Numeric) && args[1].is_a?(Numeric) && args[2].is_a?(Numeric)
        # example: new(235, 129, 74)
        rgb_init(args[0], args[1], args[2])
      elsif args.length == 4 && [:rgb, :hsl].include?(args[0]) && args[1].is_a?(Numeric) && args[2].is_a?(Numeric) && args[3].is_a?(Numeric)
        # example: new(:hsl, 320, 96, 74)
        rgb_init(args[1], args[2], args[3]) if args[0] == :rgb
        # example: new(:rgb, 235, 129, 74)
        hsl_init(args[1], args[2], args[3]) if args[0] == :hsl
      elsif args.length == 0
        # example: new()
        rgb_init(0, 0, 0)
      else
        raise(ArgumentError, "Invalid arguments")
      end
    end

    def red=(val)
      @red = range_validator(val, 0..255)
      update_hsl
      update_hex
    end

    def green=(val)
      @green = range_validator(val, 0..255)
      update_hsl
      update_hex
    end

    def blue=(val)
      @blue = range_validator(val, 0..255)
      update_hsl
      update_hex
    end

    def lightness=(val)
      @lightness = range_validator(val, 0..100)
      update_rgb
      update_hex
    end

    def saturation=(val)
      @saturation = range_validator(val, 0..100)
      update_rgb
      update_hex
    end

    def hue=(val)
      @hue = range_validator(val, 0..360)
      update_rgb
      update_hex
    end

    def hex=(val)
      raise(ArgumentError, "Invalid Hex String") unless val.length == 6 && /^[[:xdigit:]]+$/ === val
      @hex = val.upcase
      @red = val[0..1].hex
      @green = val[2..3].hex
      @blue = val[4..5].hex
      update_hsl
    end

    def hsl
      [self.hue.to_i, self.saturation.to_i, self.lightness.to_i]
    end

    def hsv
      hh = self.hue / 100.0
      ss = self.saturation / 100.0
      ll = self.lightness / 100.0

      h = hh
      ll = ll * 2
      ss = ss * ((ll <= 1 ? ll : 2) - ll)
      v = (ll + ss) / 2
      s = (2 * ss) / (ll + ss)

      [self.hue.to_i, self.saturation.to_i, (v*100).to_i]
    end

    def family
      h, s, v = self.hsv
      family = nil

      # Find if we have Black or White
      if 0 <= s && s <= 5
        if 0 <= v && v < 10
          return 'black'
        elsif 10 <= v && v < 95
          return 'gray'
        else
          return 'white'
        end
      end

      # Find color family base on Hue
      if 0 <= h && h < 82

        # We first check for Brown and Beige which are special
        #brown_v = 65.839-0.312*h
        #beige_v = 93.767-0.169*h
        #beige_s = 37.383-0.1759*h
        #brown_s = 49.095-0.208*h
        #beige_l = 37.383-0.1759*h
        #brown_l = 65.839-0.312*h
        #print 'brown_v and s: ', brown_v, brown_s
        #print 'beige_v and s: ', beige_v, beige_s

        # Check Hue by value
        if 0 <= h && h < 16
          family = 'red'
        elsif 16 <= h && h < 46 # In the xls we see 10-55
          if 40 < s && s < 60
            family = 'brown'
          elsif 20 < s && s < 41
            family = 'beige'
          end
          family = 'orange'
        elsif 46 <= h && h < 66 # In the xls we see 45-65
          if 40 < s && s < 50
            family = 'brown'
          elsif 20 < s && s < 41
            family = 'beige'
          end
          family = 'yellow'
        elsif 66 <= h && h < 121
          family = 'yellow/green'
        end
      elsif 66 <= h && h < 118
        family = 'yellow/green'
      elsif 118 <= h && h < 176
        family = 'green'
      elsif 176 <= h && h < 196
        family = 'cyan'
      elsif 196 <= h && h < 266
        family = 'blue'
      elsif 266 <= h && h < 296
        family = 'violet'
      elsif 296 <= h && h < 320
        family = 'magenta'
      elsif 320 <= h && h < 361
        family = 'red'
      end

      family
    end

    def shade
      case(self.lightness.to_i)
        when 10..39
          'dark'
        when 40..59
          'medium'
        when 60..89
          'light'
        when 90..100
          'very light'
        else
          'very dark'
      end
    end

    # Determine the equality of the receiver and another {Color}
    # @param [Color] color color to compare
    # @return [Boolean]
    def ==(color)
      color.is_a?(Color) ? (self.hex == color.hex) : false
    end

    # Create a copy of the receiver and lighten it by a percentage
    # @param [Number] percentage percentage by which to lighten the {Color}
    # @return [Color] a lightened copy of the receiver
    def lighten(percentage = 5)
      copy = self.dup
      copy.lighten!(percentage)
      copy
    end

    # Lighten the receiver by a percentage
    # @param [Number] percentage percentage by which to lighten the {Color}
    # @return [Color] self
    def lighten!(percentage = 5)
      @lightness += percentage
      @lightness = 100 if @lightness > 100
      update_rgb
      update_hex
      self
    end

    # Create a copy of the receiver and darken it by a percentage
    # @param [Number] percentage percentage by which to darken the {Color}
    # @return [Color] a darkened copy of the receiver
    def darken(percentage = 5)
      copy = self.dup
      copy.darken!(percentage)
      copy
    end

    # Darken the receiver by a percentage
    # @param [Number] percentage percentage by which to darken the {Color}
    # @return [Color] self
    def darken!(percentage = 5)
      @lightness -= percentage
      @lightness = 0 if @lightness < 0
      update_rgb
      update_hex
      self
    end

    # Create a copy of the receiver and invert it
    # @return [Color] an inverted copy of the receiver
    def invert
      copy = self.class.new(self)
      copy.invert!
      copy
    end

    # Invert the receiver
    # @return [Color] self
    def invert!
      @red = 255 - @red
      @green = 255 - @green
      @blue = 255 - @blue
      update_hsl
      update_hex
      self
    end

    # Create a copy of the receiver and desaturate it
    # @return [Color] a desaturated copy of the receiver
    def desaturate
      copy = self.class.new(self)
      copy.desaturate!
      copy
    end

    # Desaturate the receiver
    # @return [Color] self
    def desaturate!
      @saturation = 0
      update_rgb
      update_hex
      self
    end

    # Create a new {Color} that is the complement of the receiver
    # @return [Color] a desaturated copy of the receiver
    def complement
      copy = self.class.new(self)
      copy.complement!
      copy
    end

    # Turn the receiver into it's complement
    # @return [Color] self
    def complement!
      @hue = (@hue + 180) % 360
      update_rgb
      update_hex
      self
    end

    # Calculate the similarity between the receiver and another {Color}
    # @param [Color] color color to calculate the similarity to
    # @return [Number] a value in [0..1] with 0 being identical and 1 being as dissimilar as possible
    def similarity(color)
      distance({ :r => @red, :g => @green, :b => @blue}, { :r => color.red, :g => color.green, :b => color.blue}) / sqrt(3 * (255 ** 2))
    end

    # Return an array representation of a {Color} instance,
    # @param [Symbol] model the color model, should be :rgb or :hsl
    # @return [Array] an array of component values
    def to_array(color_model = :rgb)
      color_model = color_model.to_sym unless color_model.is_a? Symbol
      if color_model == :rgb
        array = [self.red, self.green, self.blue]
      elsif color_model == :hsl
        array = [self.hue, self.saturation, self.lightness]
      else
        raise(ArgumentError, "Argument must be :rgb or :hsl")
      end
      array
    end

    private

    def rgb_init(red = 0, green = 0, blue = 0)
      self.red = red
      self.green = green
      self.blue = blue
    end

    def hsl_init(hue = 0, saturation = 0, lightness = 0)
      self.hue = hue
      self.saturation = saturation
      self.lightness = lightness
    end

    def hex_init(val = "000000")
      self.hex = val
    end

    def update_hsl
      r = @red / 255.0 rescue 0.0
      g = @green / 255.0 rescue 0.0
      b = @blue / 255.0 rescue 0.0

      min = [r, g, b].min
      max = [r, g, b].max
      delta = max - min

      h = 0
      l = (max + min) / 2.0
      if ![1, 0].include?(l) && delta / 2.0  == l
        s = 1.0
      else
        s = ((l == 0 || l == 1) ? 0 : (delta / (1 - (2 * l - 1).abs)))
      end

      if delta != 0
        case max
        when r; h = ((g - b) / delta) % 6
        when g; h = ((b - r) / delta) + 2
        when b; h = ((r - g) / delta) + 4
        end
      end

      @hue = (h * 60.0).round(8)
      @hue += 360 if @hue < 0
      @saturation = (s * 100.0).round(8)
      @lightness = (l * 100.0).round(8)
    end

    def update_rgb
      h = @hue / 60.0 rescue 0.0
      s = @saturation / 100.0 rescue 0.0
      l = @lightness / 100.0 rescue 0.0

      d1 = (1 - (2 * l - 1).abs) * s
      d2 = d1 * (1 - (h % 2 - 1).abs)
      d3 = l - (d1 / 2.0)

      case h.to_i
      when 0; @red, @green, @blue = d1, d2, 0
      when 1; @red, @green, @blue = d2, d1, 0
      when 2; @red, @green, @blue = 0, d1, d2
      when 3; @red, @green, @blue = 0, d2, d1
      when 4; @red, @green, @blue = d2, 0, d1
      when 5; @red, @green, @blue = d1, 0, d2
      else; @red, @green, @blue = 0, 0, 0
      end

      @red = (255 * (@red + d3)).to_i
      @green = (255 * (@green + d3)).to_i
      @blue = (255 * (@blue + d3)).to_i
    end

    def update_hex
      r = @red.to_i.to_s(16) rescue "00"
      g = @green.to_i.to_s(16) rescue "00"
      b = @blue.to_i.to_s(16) rescue "00"
      r = "0#{r}" if r.length < 2
      g = "0#{g}" if g.length < 2
      b = "0#{b}" if b.length < 2
      @hex = "#{r}#{g}#{b}".upcase
    end

    def range_validator(val, range)
      range.include?(val) ? val : raise(ArgumentError, "Component range exceeded")
    end
  end
end
