require 'fastlane_core'

module Badge
  class Options
    AVAILABLE_GRAVITIES = %w(NorthWest North NorthEast West Center East SouthWest South SouthEast)
    def self.available_options
      [
        FastlaneCore::ConfigItem.new(key: :dark,
                                     description: "Adds a dark badge instead of the white",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :alpha,
                                     description: "Uses the work alpha instead of beta",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :alpha_channel,
                                     description: "Keeps/Adds an alpha channel to the icons",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :custom,
                                     description: "Overlay a custom image on your icon",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :no_badge,
                                     description: "Removes the beta badge",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :badge_gravity,
                                     description: "Position of the badge on icon. Default: SouthEast - Choices include: #{AVAILABLE_GRAVITIES.join(', ')}",
                                     verify_block: proc do |value|
                                       UI.user_error!("badge_gravity #{value} is invalid") unless AVAILABLE_GRAVITIES.map(&:upcase).include? value.upcase
                                     end,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield,
                                     description: "Overlay a shield from shields.io on your icon, eg: Version-1.2-green",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_parameters,
                                     description: "Parameters of the shield image. String of key-value pairs separated by ampersand as specified on shields.io, eg: colorA=abcdef&style=flat",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_io_timeout,
                                     description: "The timeout in seconds we should wait the get a response from shields.io",
                                     type: Integer,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_geometry,
                                     description: "Position of shield on icon, relative to gravity e.g, +50+10%",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_gravity,
                                     description: "Position of shield on icon. Default: North - Choices include: #{AVAILABLE_GRAVITIES.join(', ')}",
                                     verify_block: proc do |value|
                                       UI.user_error!("badge_gravity #{value} is invalid") unless AVAILABLE_GRAVITIES.map(&:upcase).include? value.upcase
                                     end,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_scale,
                                     description: "Shield image scale factor; e.g, 0.5, 2, etc. - works with --shield_no_resize",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_no_resize,
                                     description: "Shield image will no longer be resized to aspect fill the full icon. Instead it will only be shrinked to not exceed the icon graphic",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :glob,
                                     description: "Glob pattern for finding image files Default: CURRENT_PATH/**/*.appiconset/*.{png,PNG}",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :grayscale,
                                     description: "Whether making icons to grayscale",
                                     is_string: false,
                                     default_value: false,
                                     optional: true)
      ]
    end
  end
end
