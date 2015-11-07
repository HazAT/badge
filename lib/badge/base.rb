module Badge

	VERSION = "0.0.4"
	DESCRIPTION = "Add a badge overlay to your app icon"

	def self.root
		File.dirname __dir__ + "/../../../"
	end

	def self.assets
		File.join root, 'assets'
	end

	def self.light_badge
		File.join assets, 'beta_badge_light.png'
	end

	def self.dark_badge
		File.join assets, 'beta_badge_dark.png'
	end

	def self.shield_base_url
		'https://img.shields.io'
	end

	def self.shield_path
		'/badge/'
	end

end
