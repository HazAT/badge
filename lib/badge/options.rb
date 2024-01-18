require 'fastlane_core'

module Badge
  class Options
    AVAILABLE_GRAVITIES = %w(NorthWest North NorthEast West Center East SouthWest South SouthEast)
    def self.available_options
      [
        FastlaneCore::ConfigItem.new(key: :dark,
                                     env_name: "BADGE_DARK",
                                     description: "Adds a dark badge instead of the white",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :alpha,
                                     env_name: "BADGE_ALPHA",
                                     description: "Uses the word alpha instead of beta",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :alpha_channel,
                                     env_name: "BADGE_ALPHA_CHANNEL",
                                     description: "Keeps/Adds an alpha channel to the icons",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :custom,
                                     env_name: "BADGE_CUSTOM",
                                     description: "Overlay a custom image on your icon",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :no_badge,
                                     env_name: "BADGE_NO_BADGE",
                                     description: "Removes the beta badge",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :badge_gravity,
                                     env_name: "BADGE_GRAVITY",
                                     description: "Position of the badge on icon. Default: SouthEast - Choices include: #{AVAILABLE_GRAVITIES.join(', ')}",
                                     verify_block: proc do |value|
                                       UI.user_error!("badge_gravity #{value} is invalid") unless AVAILABLE_GRAVITIES.map(&:upcase).include? value.upcase
                                     end,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield,
                                     env_name: "BADGE_SHIELD",
                                     description: "Overlay a shield from shields.io on your icon, eg: Version-1.2-green",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_parameters,
                                     env_name: "BADGE_SHIELD_PARAMETERS",
                                     description: "Parameters of the shield image. String of key-value pairs separated by ampersand as specified on shields.io, eg: colorA=abcdef&style=flat",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_io_timeout,
                                     env_name: "BADGE_SHIELD_IO_TIMEOUT",
                                     description: "The timeout in seconds we should wait to get a response from shields.io",
                                     type: Integer,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_geometry,
                                     env_name: "BADGE_SHIELD_GEOMETRY",
                                     description: "Position of shield on icon, relative to gravity e.g, +50+10%",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_gravity,
                                     env_name: "BADGE_SHIELD_GRAVITY",
                                     description: "Position of shield on icon. Default: North - Choices include: #{AVAILABLE_GRAVITIES.join(', ')}",
                                     verify_block: proc do |value|
                                       UI.user_error!("badge_gravity #{value} is invalid") unless AVAILABLE_GRAVITIES.map(&:upcase).include? value.upcase
                                     end,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_scale,
                                     env_name: "BADGE_SHIELD_SCALE",
                                     description: "Shield image scale factor; e.g, 0.5, 2, etc. - works with --shield_no_resize",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :shield_no_resize,
                                     env_name: "BADGE_SHIELD_NO_RESIZE",
                                     description: "Shield image will no longer be resized to aspect fill the full icon. Instead it will only be shrunk to not exceed the icon graphic",
                                     is_string: false,
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :glob,
                                     env_name: "BADGE_GLOB",
                                     description: "Glob pattern for finding image files. Default: CURRENT_PATH/**/*.appiconset/*.{png,PNG}",
                                     optional: true),

        FastlaneCore::ConfigItem.new(key: :grayscale,
                                     env_name: "BADGE_GRAYSCALE",
                                     description: "Whether making icons to grayscale",
                                     is_string: false,
                                     default_value: false,
                                     optional: true)
      ]
    end
  end
end
