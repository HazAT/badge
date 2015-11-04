require 'fastimage'
require 'mini_magick'

module Badge
  class Runner

    def run(path, dark_badge, custom_badge)
      app_icons = Dir.glob("#{path}/**/*.appiconset/*.{png,PNG}")

      if app_icons.count > 0
        Helper.log.info "Start adding badges...".green

        app_icons.each do |full_path|
          Helper.log.info "'#{full_path}'"
          icon_path = Pathname.new(full_path)
          icon = MiniMagick::Image.new(full_path)
          
          if custom_badge && File.exist?(custom_badge) # check if custom image is provided
            badge = MiniMagick::Image.open(custom_badge)
          else
            badge = MiniMagick::Image.open(dark_badge ? Badge.dark_badge : Badge.light_badge)
          end
          
          badge.resize "#{icon.width}x#{icon.height}"
          result = icon.composite(badge) do |c|
            c.compose "Over"
          end
          result.write full_path
        end

        Helper.log.info "Badged \\o/!".green
      else
        Helper.log.error "Could not find any app icons...".red
      end
    end
  end
end
