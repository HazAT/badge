module Badge
  VERSION = "0.0.1"
  DESCRIPTION = "Add a badge overlay to your app icon"
  
  def self.root
    File.dirname __dir__ + "/../../../"
  end

  def self.assets
    File.join root, 'assets'
  end
end
