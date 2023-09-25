
I18n.load_path += Dir[File.expand_path("config/locales") + "/**/*.yml"]

module I18n
  def self.just_raise_that_exception(*args)
    raise "i18n: #{args.first}"
  end
end
I18n.exception_handler = :just_raise_that_exception
