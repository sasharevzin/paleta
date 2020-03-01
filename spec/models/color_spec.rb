require "spec_helper"

describe Paleta::Color do
  it "should initialize with RGB components in 0..255" do
    color = Paleta::Color.new(94, 161, 235)
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end

  it "should initialize with the :hex flag and a valid 6 character HEX string" do
    color = Paleta::Color.new(:hex, "5EA1EB")
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end

  it "should initialize with the :hex flag and a valid 7 character HEX string" do
    color = Paleta::Color.new(:hex, "#5EA1EB")
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end

  it "should initialize with the :hex flag and a valid 3 character HEX string" do
    color = Paleta::Color.new(:hex, "5EA")
    color.red.should == 85
    color.green.should == 238
    color.blue.should == 170
  end

  it "should initialize with the :hex flag and a valid 4 character HEX string" do
    color = Paleta::Color.new(:hex, "#5EA")
    color.red.should == 85
    color.green.should == 238
    color.blue.should == 170
  end

  it "should initialize with the :hsl flag, hue in 0..360, and saturation and lightness in 0..100" do
    color = Paleta::Color.new(:hsl, 0, 0, 100)
    color.hue.should == 0
    color.saturation.should == 0
    color.lightness.should == 100
    color.red.should == 255
    color.green.should == 255
    color.blue.should == 255
    color.hex.should == "FFFFFF"
  end

  it "should initialize with the :rgb flag with RGB components in 0..255" do
    color = Paleta::Color.new(:rgb, 94, 161, 235)
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end

  it "should raise an error on an invalid format flag" do
    expect { Paleta::Color.new(:something, 50, 50, 50) }.to raise_error(ArgumentError)
  end

  it "should raise an error on an invalid hex string" do
    expect { Paleta::Color.new(:hex, "xkfjs") }.to raise_error(ArgumentError)
  end

  it "should raise an error on RGB components not in 0..255" do
    expect { Paleta::Color.new(-74, 333, 4321) }.to raise_error(ArgumentError)
  end

  it "should raise an error on hue not in 0..360" do
    expect { Paleta::Color.new(:hsl, 400, 50, 50) }.to raise_error(ArgumentError)
  end

  it "should raise an error on saturation not in 0..100" do
    expect { Paleta::Color.new(:hsl, 200, 150, 50) }.to raise_error(ArgumentError)
  end

  it "should raise an error on lightness not in 0..100" do
    expect { Paleta::Color.new(:hsl, 200, 50, 150) }.to raise_error(ArgumentError)
  end

  it "should determine its equality to another Color" do
    color1 = Paleta::Color.new(237, 172, 33)
    color2 = Paleta::Color.new(:hex, "EDAC21")
    (color1 == color2).should be true
    color3 = Paleta::Color.new(:hsl, 200, 50, 100)
    (color1 == color3).should be false
    obj = Object.new
    (color1 == obj).should be false
  end

  it "should calculate its HSL value on itialization" do
    color = Paleta::Color.new(237, 172, 33)
    color.hue.to_i.should == 40
    color.saturation.to_i.should == 85
    color.lightness.to_i.should == 52
  end

  it "should update its HSL value when its RGB value is updated" do
    color = Paleta::Color.new(237, 172, 33)

    color.red = 0
    color.hue.to_i.should == 131
    color.saturation.to_i.should == 100
    color.lightness.to_i.should == 33

    color.green = 123
    color.hue.to_i.should == 136
    color.saturation.to_i.should == 100
    color.lightness.to_i.should == 24

    color.blue = 241
    color.hue.to_i.should == 209
    color.saturation.to_i.should == 100
    color.lightness.to_i.should == 47
  end

  it "should update its RGB value when its HSL value is updated" do
    color = Paleta::Color.new(0, 0, 255)
    color.hue = 120
    color.red.to_i.should == 0
    color.green.to_i.should == 255
    color.blue.to_i.should == 0

    color.saturation = 50
    color.red.to_i.should == 63
    color.green.to_i.should == 191
    color.blue.to_i.should == 63

    color.lightness = 80
    color.red.to_i.should == 178
    color.green.to_i.should == 229
    color.blue.to_i.should == 178
  end

  it "should lighten itself by a percentage" do
    color = Paleta::Color.new(94, 161, 235)
    lightness = color.lightness
    color.lighten!
    color.lightness.should == lightness + 5
    lightness = color.lightness
    color.lighten!(20)
    color.lightness.should == lightness + 20
  end

  it "should return a copy of itself, lightened by a percentage" do
    color = Paleta::Color.new(94, 161, 235)
    lightness = color.lightness
    copy = color.lighten(20)
    copy.lightness.should == lightness + 20
    color.lightness.should == lightness
  end

  it "should quietly maintain a maximum of 100 when lightening" do
    color = Paleta::Color.new(94, 161, 235)
    color.lighten!(300)
    color.lightness.should == 100
  end

  it "should darken by a percentage" do
    color = Paleta::Color.new(94, 161, 235)
    lightness = color.lightness
    color.darken!
    color.lightness.should == lightness - 5
    lightness = color.lightness
    color.darken!(20)
    color.lightness.should == lightness - 20
  end

  it "should return a copy of itself, darkened by a percentage" do
    color = Paleta::Color.new(94, 161, 235)
    lightness = color.lightness
    copy = color.darken(20)
    copy.lightness.should == lightness - 20
    color.lightness.should == lightness
  end

  it "should quietly maintain a minimum of 0 when darkening" do
    color = Paleta::Color.new(94, 161, 235)
    color.darken!(300)
    color.lightness.should == 0
  end

  it "should invert" do
    color = Paleta::Color.new(94, 161, 235)
    color.invert!
    color.red.should == 161
    color.green.should == 94
    color.blue.should == 20
  end

  it "should return an inverted copy of itself" do
    color = Paleta::Color.new(94, 161, 235)
    copy = color.invert
    copy.red.should == 161
    copy.green.should == 94
    copy.blue.should == 20
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end

  it "should desaturate" do
    color = Paleta::Color.new(94, 161, 235)
    color.desaturate!
    color.saturation.should == 0
    color.red.to_i.should == 164
    color.green.to_i.should == 164
    color.blue.to_i.should == 164
  end

  it "should return a desaturated copy of itself" do
    color = Paleta::Color.new(94, 161, 235)
    copy = color.desaturate
    copy.saturation.should == 0
    copy.red.to_i.should == 164
    copy.green.to_i.should == 164
    copy.blue.to_i.should == 164
    color.saturation.to_i.should == 77
    color.red.should == 94
    color.green.should == 161
    color.blue.should == 235
  end

  it "should become its complement" do
    color = Paleta::Color.new(:hsl, 90, 50, 50)
    color.complement!
    color.hue.to_i.should == 270
  end

  it "should return its complement Color" do
    color = Paleta::Color.new(:hsl, 90, 50, 50)
    complement = color.complement
    complement.hue.to_i.should == 270
  end

  it "should calculate its similarity to another Color" do
    color1 = Paleta::Color.new(94, 161, 235)
    color2 = Paleta::Color.new(237, 172, 33)
    color1.similarity(color2).round(5).should == 0.56091

    color1 = Paleta::Color.new(237, 172, 33)
    color2 = Paleta::Color.new(237, 172, 33)
    color1.similarity(color2).should == 0

    color1 = Paleta::Color.new(0, 0, 0)
    color2 = Paleta::Color.new(255, 255, 255)
    color1.similarity(color2).should == 1
  end

  it "should maintain its HEX value" do
    color = Paleta::Color.new(94, 161, 235)
    color.hex.should == "5EA1EB"
  end

  it "should update its HSB and RGB components when its HEX value is updated" do
    color = Paleta::Color.new(100, 100, 100)
    color.hex = "ffffff"
    color.red.should == 255
    color.green.should == 255
    color.blue.should == 255
    color.hue.should == 0
    color.saturation.should == 0
    color.lightness.should == 100
  end

  it "should return an array of component values" do
    c = Paleta::Color.new(30, 90, 120)
    rgb_array = [c.red, c.green, c.blue]
    hsl_array = [c.hue, c.saturation, c.lightness]
    c.to_array.should == rgb_array
    c.to_array(:rgb).should == rgb_array
    c.to_array(:hsl).should == hsl_array
  end
end
