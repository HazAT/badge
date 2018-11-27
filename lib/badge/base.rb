module Badge

	VERSION = "0.10.0"
	DESCRIPTION = "Add a badge overlay to your app icon"

	def self.root
		File.dirname __dir__ + "/../../../"
	end

	def self.assets
		File.join root, 'assets'
	end

	def self.beta_light_badge
		File.join assets, 'beta_badge_light.png'
	end

	def self.beta_dark_badge
		File.join assets, 'beta_badge_dark.png'
	end

	def self.alpha_light_badge
		File.join assets, 'alpha_badge_light.png'
	end

	def self.alpha_dark_badge
		File.join assets, 'alpha_badge_dark.png'
	end

	def self.shield_base_url
		'https://img.shields.io'
	end

	def self.shield_path
		'/badge/'
	end

	def self.shield_io_timeout
		10
	end

	def self.shield_io_retries
		10
	end

end
