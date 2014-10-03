require 'tilt'
require 'konacha/engine'
require 'konacha/runner'
require 'konacha/server'
require 'konacha/reporter'
require 'konacha/formatter'

module Konacha
  class << self
    attr_accessor :mode

    def serve
      puts 'Your tests are here:'
      puts "  http://localhost:#{port}/"
      self.mode = :server
      Konacha::Server.start
    end

    def run
      self.mode = :runner
      Konacha::Runner.start
    end

    def config
      Konacha::Engine.config.konacha
    end

    def configure
      yield config
    end

    delegate :port, :spec_dir, :spec_matcher, :application, :driver, :runner_port, :formatters, to: :config

    def spec_root
      File.join(Rails.root, config.spec_dir)
    end

    def spec_paths
      Rails.application.assets.each_entry(spec_root).select do |pathname|
        config.spec_matcher === pathname.basename.to_s &&
        (pathname.extname == '.js' || Tilt[pathname]) &&
        Rails.application.assets.content_type_of(pathname) == 'application/javascript'
      end.map do |pathname|
        pathname.to_s.gsub(File.join(spec_root, ''), '')
      end.sort
    end
  end
end
