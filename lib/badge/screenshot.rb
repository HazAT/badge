module AppscreensIoUploader
  # Represents one screenshot
  class Screenshot
    attr_accessor :path # path to the screenshot
    attr_accessor :size # size in px array of 2 elements: height and width
    attr_accessor :language # 2 letter language code parsed out of file name - if not found en is used
    attr_accessor :screen_size # deliver screen size type, is unique per device type, used in device_name

    # path: Path to screenshot
    # color: Color to use for the frame
    def initialize(path)
      raise "Couldn't find file at path '#{path}'".red unless File.exists?path
      @path = path
      @size = FastImage.size(path)

      matched_language = /\/([a-zA-Z]{2})-/.match(path)
      if matched_language
        @language = matched_language.captures[0]
      else
        @language = 'en'
        Helper.log.info "cannot find language in filename fallback to 'en' file: #{path}"
      end

      @screen_size = Deliver::AppScreenshot.calculate_screen_size(path)
    end

    def is_supported_screen_size?
      sizes = Deliver::AppScreenshot::ScreenSize
      case @screen_size
        when sizes::IOS_55
          return true
        when sizes::IOS_47
          return true
        when sizes::IOS_40
          return true
        when sizes::IOS_35
          return false
        when sizes::IOS_IPAD
          return false
        when sizes::MAC
          return false
      end
    end

    # The name of the orientation of a screenshot. Used to find the correct template
    def orientation_name
      return Orientation::PORTRAIT if size[0] < size[1]
      return Orientation::LANDSCAPE
    end

    def is_portrait?
      return (orientation_name == Orientation::PORTRAIT)
    end

    def to_s
      self.path
    end

  end
end
