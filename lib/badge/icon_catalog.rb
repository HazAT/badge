require 'json'
require 'pathname'

module Badge
  class IconCatalog
    attr_reader :path, :format_type, :icon_files

    FORMAT_LEGACY = :legacy
    FORMAT_SINGLE_SIZE = :single_size
    FORMAT_LAYERED = :layered

    def initialize(appiconset_path)
      @path = Pathname.new(appiconset_path)
      @contents_json_path = @path.join('Contents.json')
      @icon_files = []
      @format_type = nil

      detect_format
    end

    # Returns list of icon file paths that should be badged
    def badgeable_icons
      case @format_type
      when FORMAT_LAYERED
        # For layered icons, badge all variants (all.png, dark.png, tint.png)
        @icon_files
      when FORMAT_SINGLE_SIZE
        # Single size format - badge the single icon
        @icon_files
      when FORMAT_LEGACY
        # Legacy format - badge all size variants
        @icon_files
      else
        # Fallback to glob if format detection failed
        glob_fallback
      end
    end

    def self.find_catalogs(search_path, glob_pattern = nil)
      if glob_pattern
        # Use custom glob if provided (backward compatibility)
        UI.verbose "Using custom glob pattern: #{glob_pattern}".blue
        return glob_pattern
      end

      # Find all .appiconset directories
      appiconset_dirs = Dir.glob("#{search_path}/**/*.appiconset")

      catalogs = appiconset_dirs.map { |dir| new(dir) }
      UI.verbose "Found #{catalogs.count} app icon catalog(s)".blue
      catalogs.each do |catalog|
        UI.verbose "  - #{catalog.path.basename} (#{catalog.format_type})".blue
      end

      catalogs
    end

    private

    def detect_format
      unless File.exist?(@contents_json_path)
        UI.verbose "No Contents.json found at #{@contents_json_path}, using fallback".yellow
        @format_type = :unknown
        return
      end

      begin
        contents = JSON.parse(File.read(@contents_json_path))
        images = contents['images'] || []

        if images.empty?
          UI.verbose "Contents.json has no images array".yellow
          @format_type = :unknown
          return
        end

        # Check for layered format (iOS 18+)
        # Layered icons have images with "appearances" array containing luminosity variants
        has_appearances = images.any? { |img| img['appearances'] }

        if has_appearances
          @format_type = FORMAT_LAYERED
          @icon_files = extract_layered_icons(images)
          UI.verbose "Detected layered icon format with #{@icon_files.count} variant(s)".blue
          return
        end

        # Check for single-size format (Xcode 14+)
        # Single size has one image with size "1024x1024" and "idiom" = "universal"
        if images.count == 1 && images[0]['size'] == '1024x1024'
          @format_type = FORMAT_SINGLE_SIZE
          @icon_files = extract_icon_files(images)
          UI.verbose "Detected single-size icon format".blue
          return
        end

        # Legacy multi-size format
        @format_type = FORMAT_LEGACY
        @icon_files = extract_icon_files(images)
        UI.verbose "Detected legacy multi-size icon format with #{@icon_files.count} size(s)".blue

      rescue JSON::ParserError => e
        UI.error "Failed to parse Contents.json: #{e.message}".red
        @format_type = :unknown
      end
    end

    def extract_layered_icons(images)
      extract_icon_files(images)
    end

    def extract_icon_files(images)
      images.map do |image|
        filename = image['filename']
        next unless filename

        icon_path = @path.join(filename)
        icon_path.to_s if File.exist?(icon_path) && icon_path.extname.downcase == '.png'
      end.compact
    end

    def glob_fallback
      Dir.glob("#{@path}/*.{png,PNG}")
    end
  end
end
