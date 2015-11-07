require 'fastimage'
require 'mini_magick'

module Badge
  class Runner
  
    def load_shield()
      url = Badge.shield_base_url + Badge.shield_path + "build-432355-green" + ".png"
      file_name = "build-432355-green" + ".png"

      shield = Tempfile.new(file_name).tap do |file|
        file.binmode
        file.write(open(url).read)
        file.close
      end

      shield
    end

    def run(path, dark_badge, custom_badge)
      app_icons = Dir.glob("#{path}/**/*.appiconset/*.{png,PNG}")

      if app_icons.count > 0
        Helper.log.info "Start adding badges...".green

        shield = load_shield()

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

          current_shield = MiniMagick::Image.open(shield.path)
          current_shield.resize "#{icon.width}x#{icon.height}>"
          result = result.composite(current_shield) do |c|
            c.compose "Over"
            c.gravity "north" 
            c.geometry "+0+2"
          end

          result.format "png"
          result.write full_path
        end

        Helper.log.info "Badged \\o/!".green
      else
        Helper.log.error "Could not find any app icons...".red
      end
    end
  end
end
