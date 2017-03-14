require 'commander'

HighLine.track_eof = false

module Badge
  class CommandsGenerator

    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :version, Badge::VERSION
      program :description, 'Add a badge to your app icon'
      program :help, 'Author', 'Daniel Griesser <daniel.griesser.86@gmail.com>'
      program :help, 'Website', 'https://github.com/HazAT/badge'
      program :help, 'GitHub', 'https://github.com/HazAT/badge'
      program :help_formatter, :compact

      global_option('--verbose', 'Shows a more verbose output') { FastlaneCore::Globals.verbose = true }

      always_trace!

      FastlaneCore::CommanderGenerator.new.generate(Badge::Options.available_options)

      command :run do |c|
        c.syntax = 'badge'
        c.description = "Adds a badge to your app icon"

        c.action do |args, options|
          params = FastlaneCore::Configuration.create(Badge::Options.available_options, options.__hash__)
          Badge::Runner.new.run('.', params)
        end
      end

      default_command :run
      run!
    end
  end
end
