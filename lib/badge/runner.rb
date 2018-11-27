require 'fastimage'
require 'timeout'
require 'mini_magick'
require 'curb'

module Badge
  class Runner
    @@retry_attemps = 0
    @@rsvg_enabled = true

    def run(path, options)
      check_tools!
      glob = "/**/*.appiconset/*.{png,PNG}"
      glob = options[:glob] if options[:glob]

      app_icons = Dir.glob("#{path}#{glob}")
      UI.verbose "Verbose active... VERSION: #{Badge::VERSION}".blue
      UI.verbose "Parameters: #{options.values.inspect}".blue

      if options[:custom] && !File.exist?(options[:custom])
        UI.error("Could not find custom badge image")
        UI.user_error!("Specify a valid custom badge image path!")
      end

      alpha_channel = false
      if options[:alpha_channel]
        alpha_channel = true
      end

      if app_icons.count > 0
        UI.message "Start adding badges...".green

        shield = nil
        begin
          timeout = Badge.shield_io_timeout
          timeout = options[:shield_io_timeout] if options[:shield_io_timeout]
          Timeout.timeout(timeout.to_i) do
            shield = load_shield(options[:shield], options[:shield_parameters]) if options[:shield]
          end
        rescue Timeout::Error
          UI.error "Error loading image from shields.io timeout reached. Use --verbose for more info".red
        rescue Curl::Err::CurlError => error
          response = error.io
          UI.error "Error loading image from shields.io response Error. Use --verbose for more info".red
          UI.verbose response.status if FastlaneCore::Globals.verbose?
        rescue MiniMagick::Invalid
          UI.error "Error validating image from shields.io. Use --verbose for more info".red
        rescue Exception => error
          UI.error "Other error occured. Use --verbose for more info".red
          UI.verbose error if FastlaneCore::Globals.verbose?
        end

        if options[:shield] && shield == nil
          if @@retry_attemps >= Badge.shield_io_retries
            UI.error "Cannot load image from shields.io skipping it...".red
          else
            UI.message "Waiting for #{timeout.to_i}s and retry to load image from shields.io tries remaining: #{Badge.shield_io_retries - @@retry_attemps}".red
            sleep timeout.to_i
            @@retry_attemps += 1
            return run(path, options)
          end
        end

        icon_changed = false
        app_icons.each do |full_path|
          icon_path = Pathname.new(full_path)
          icon = MiniMagick::Image.new(full_path)

          result = MiniMagick::Image.new(full_path)

          if options[:grayscale]
            result.colorspace 'gray'
            icon_changed = true
          end
          if !options[:no_badge]
            result = add_badge(options[:custom], options[:dark], icon, options[:alpha], alpha_channel, options[:badge_gravity])
            icon_changed = true
          end
          if shield
            result = add_shield(icon, result, shield, alpha_channel, options[:shield_gravity], options[:shield_no_resize], options[:shield_scale], options[:shield_geometry])
            icon_changed = true
          end
          if icon_changed
            result.format "png"
            result.write full_path
          end
        end
        if icon_changed
          UI.message "Badged \\o/!".green
        else
          UI.message "Did nothing... Enable --verbose for more info.".red
        end

        if shield
          File.delete(shield) if File.exist?(shield)
          File.delete("#{shield.path}.png") if File.exist?("#{shield.path}.png")
        end

      else
        UI.error "Could not find any app icons...".red
      end
    end

    def add_shield(icon, result, shield, alpha_channel, shield_gravity, shield_no_resize, shield_scale, shield_geometry)
      UI.message "'#{icon.path}'"
      UI.verbose "Adding shields.io image ontop of icon".blue

      shield_scale = shield_scale ? shield_scale.to_f : 1.0

      if @@rsvg_enabled
        new_path = "#{shield.path}.png"
        if shield_no_resize
          `rsvg-convert #{shield.path} -z #{shield_scale} -o #{new_path}`
        else
          `rsvg-convert #{shield.path} -w #{(icon.width * shield_scale).to_i} -a -o #{new_path}`
        end
        new_shield = MiniMagick::Image.open(new_path)
      else
        new_shield = MiniMagick::Image.open(shield.path)
        if icon.width > new_shield.width && !shield_no_resize
          new_shield.resize "#{(icon.width * shield_scale).to_i}x#{icon.height}<"
        else
          new_shield.resize "#{icon.width}x#{icon.height}>"
        end
      end

      result = composite(result, new_shield, alpha_channel, shield_gravity || "north", shield_geometry)
    end

    def load_shield(shield_string, shield_parameters)
      url = Badge.shield_base_url + Badge.shield_path + shield_string + (@@rsvg_enabled ? ".svg" : ".png")
      if shield_parameters
        url = url + "?" + shield_parameters
      end
      file_name = shield_string + (@@rsvg_enabled ? ".svg" : ".png")

      UI.verbose "Trying to load image from shields.io. Timeout: #{Badge.shield_io_timeout}s".blue
      UI.verbose "URL: #{url}".blue

      Curl::Easy.download(url, file_name)
      MiniMagick::Image.open(file_name) unless @@rsvg_enabled

      File.open(file_name)
    end

    def check_tools!
        if !`which rsvg-convert`.include?('rsvg-convert')
          UI.important("Install RSVG to get better results for shields on top of your icon")
          UI.important("")
          UI.important("Install it using (RSVG):")
          UI.command("brew install librsvg")
          UI.important("")
          @@rsvg_enabled = false
        end
        return if `which convert`.include?('convert')
        return if `which gm`.include?('gm')

        UI.error("You have to install ImageMagick or GraphicsMagick to use `badge`")
        UI.error("")
        UI.error("Install it using (ImageMagick):")
        UI.command("brew install imagemagick")
        UI.error("")
        UI.error("Install it using (GraphicsMagick):")
        UI.command("brew install graphicsmagick")
        UI.error("")
        UI.error("If you don't have homebrew, visit http://brew.sh")

        UI.user_error!("Install ImageMagick and start your lane again!")
    end

    def add_badge(custom_badge, dark_badge, icon, alpha_badge, alpha_channel, badge_gravity)
      UI.message "'#{icon.path}'"
      UI.verbose "Adding badge image ontop of icon".blue
      if custom_badge && File.exist?(custom_badge) # check if custom image is provided
        badge = MiniMagick::Image.open(custom_badge)
      else
        if alpha_badge
          badge = MiniMagick::Image.open(dark_badge ? Badge.alpha_dark_badge : Badge.alpha_light_badge)
        else
          badge = MiniMagick::Image.open(dark_badge ? Badge.beta_dark_badge : Badge.beta_light_badge)
        end
      end

      badge.resize "#{icon.width}x#{icon.height}"
      result = composite(icon, badge, alpha_channel, badge_gravity || "SouthEast")
    end

    def composite(image, overlay, alpha_channel, gravity, geometry = nil)
      image.composite(overlay, 'png') do |c|
        c.compose "Over"
        c.alpha 'On' unless !alpha_channel
        c.gravity gravity
        c.geometry geometry if geometry
      end
    end
  end
end
