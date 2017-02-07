require 'fastimage'
require 'timeout'
require 'mini_magick'
require 'curb'

module Badge
  class Runner
    @@retry_count = Badge.shield_io_retries

    def run(path, options)
      check_imagemagick!
      glob = "/**/*.appiconset/*.{png,PNG}"
      glob = options[:glob] if options[:glob]

      app_icons = Dir.glob("#{path}#{glob}")
      UI.verbose "Verbose active...".blue
      UI.verbose "Parameters: #{options.inspect}".blue

      alpha_channel = false
      if options[:alpha_channel]
        alpha_channel = true
      end

      if app_icons.count > 0
        UI.message "Start adding badges...".green

        shield = nil
        response_error = false
        begin
          timeout = Badge.shield_io_timeout
          timeout = options[:shield_io_timeout] if options[:shield_io_timeout]
          Timeout.timeout(timeout.to_i) do
            shield = load_shield(options[:shield]) if options[:shield]
          end
        rescue Timeout::Error
          UI.error "Error loading image from shield.io timeout reached. Skipping Shield. Use --verbose for more info".red
        rescue OpenURI::HTTPError => error
          response = error.io
          UI.error "Error loading image from shield.io response Error. Skipping Shield. Use --verbose for more info".red
          UI.error response.status if $verbose
          response_error = true
        end

        if @@retry_count <= 0
          UI.error "Cannot load image from shield.io skipping it...".red
        elsif response_error
          UI.message "Waiting for #{timeout.to_i}s and retry to load image from shield.io tries remaining: #{@@retry_count}".red
          sleep timeout.to_i
          @@retry_count -= 1
          return run(path, options)
        end

        icon_changed = false
        app_icons.each do |full_path|
          icon_path = Pathname.new(full_path)
          icon = MiniMagick::Image.new(full_path)

          result = MiniMagick::Image.new(full_path)
          
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
      else
        UI.error "Could not find any app icons...".red
      end
    end

    def add_shield(icon, result, shield, alpha_channel, shield_gravity, shield_no_resize, shield_scale, shield_geometry)
      UI.message "'#{icon.path}'"
      UI.verbose "Adding shield.io image ontop of icon".blue

      svg_shield = MiniMagick::Image.open(shield.path)
      new_path = "#{shield.path}.png"
      shield_scale = shield_scale ? shield_scale.to_f : 1.0

      if shield_no_resize
        `rsvg-convert #{shield.path} -z #{shield_scale} -o #{new_path}`
      else
        `rsvg-convert #{shield.path} -w #{(icon.width * shield_scale).to_i} -a -o #{new_path}`
      end

      png_shield = MiniMagick::Image.open(new_path)

      result = composite(result, png_shield, alpha_channel, shield_gravity || "north", shield_geometry)
    end

    def load_shield(shield_string)
      url = Badge.shield_base_url + Badge.shield_path + shield_string + ".svg"
      file_name = shield_string + ".svg"

      UI.verbose "Trying to load image from shield.io. Timeout: #{Badge.shield_io_timeout}s".blue
      UI.verbose "URL: #{url}".blue

      Curl::Easy.download(url, file_name)
      
      File.open(file_name)
    end
    
    def check_imagemagick!
        return if `which convert`.include?('convert')
        return if `which gm`.include?('gm')

        UI.error("You have to install ImageMagick or GraphicsMagick to use `badge`")
        UI.error("")
        UI.error("Install it using (ImageMagick):")
        UI.command("brew update && brew install imagemagick")
        UI.error("")
        UI.error("Install it using (GraphicsMagick):")
        UI.command("brew update && brew install graphicsmagick")
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
