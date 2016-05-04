require 'fastimage'
require 'timeout'
require 'mini_magick'

module Badge
  class Runner
    @@retry_count = Badge.shield_io_retries

    def run(path, options)
      glob = "/**/*.appiconset/*.{png,PNG}"
      glob = options[:glob] unless not options[:glob]

      app_icons = Dir.glob("#{path}#{glob}")
      Helper.log.info "Verbose active...".blue unless not $verbose
      Helper.log.info "Parameters: #{options.inspect}".blue unless not $verbose

      alpha_channel = false
      if options[:alpha_channel]
        alpha_channel = true
      end

      if app_icons.count > 0
        Helper.log.info "Start adding badges...".green

        shield = nil
        response_error = false
        begin
          timeout = Badge.shield_io_timeout
          timeout = options[:shield_io_timeout] unless not options[:shield_io_timeout]
          Timeout.timeout(timeout.to_i) do
            shield = load_shield(options[:shield]) unless not options[:shield]
          end
        rescue Timeout::Error
          Helper.log.error "Error loading image from shield.io timeout reached. Skipping Shield. Use --verbose for more info".red
        rescue OpenURI::HTTPError => error
          response = error.io
          Helper.log.error "Error loading image from shield.io response Error. Skipping Shield. Use --verbose for more info".red
          Helper.log.error response.status unless not $verbose
          response_error = true
        end

        if @@retry_count <= 0
          Helper.log.error "Cannot load image from shield.io skipping it...".red
        elsif response_error
          Helper.log.info "Waiting for #{timeout.to_i}s and retry to load image from shield.io tries remaining: #{@@retry_count}".red
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
            result = add_badge(options[:custom], options[:dark], icon, options[:alpha], alpha_channel)
            icon_changed = true
          end
          if shield
            result = add_shield(icon, result, shield, alpha_channel, options[:shield_gravity], options[:shield_no_resize])
            icon_changed = true
          end
          
          if icon_changed
            result.format "png"
            result.write full_path 
          end
        end
        if icon_changed
          Helper.log.info "Badged \\o/!".green
        else
          Helper.log.info "Did nothing... Enable --verbose for more info.".red
        end
      else
        Helper.log.error "Could not find any app icons...".red
      end
    end

    def add_shield(icon, result, shield, alpha_channel, shield_gravity, shield_no_resize)
      Helper.log.info "'#{icon.path}'"
      Helper.log.info "Adding shield.io image ontop of icon".blue unless not $verbose

      current_shield = MiniMagick::Image.open(shield.path)
      
      if icon.width > current_shield.width && !shield_no_resize
        current_shield.resize "#{icon.width}x#{icon.height}<"
      else
        current_shield.resize "#{icon.width}x#{icon.height}>"
      end
      
      result = result.composite(current_shield, 'png') do |c|
        c.compose "Over"
        c.alpha 'On' unless !alpha_channel
        if shield_gravity
          c.gravity shield_gravity
        else
          c.gravity "north"
        end
      end
    end

    def load_shield(shield_string)
      url = Badge.shield_base_url + Badge.shield_path + shield_string + ".png"
      file_name = shield_string + ".png"

      Helper.log.info "Trying to load image from shield.io. Timeout: #{Badge.shield_io_timeout}s".blue unless not $verbose
      Helper.log.info "URL: #{url}".blue unless not $verbose

      shield = Tempfile.new(file_name).tap do |file|
        file.binmode
        file.write(open(url).read)
        file.close
      end
    end

    def add_badge(custom_badge, dark_badge, icon, alpha_badge, alpha_channel)
      Helper.log.info "'#{icon.path}'"
      Helper.log.info "Adding badge image ontop of icon".blue unless not $verbose
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
      result = icon.composite(badge, 'png') do |c|
        c.compose "Over"
        c.alpha 'On' unless !alpha_channel
      end
    end
  end
end
