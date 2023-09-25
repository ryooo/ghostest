require 'digest'
class I18nTranslator
  def self.update_dictionary!(from_locale, to_locales)
    from_file_paths = I18n.load_path.select { |path| path.match(/#{from_locale}\.yml$/) }
    from_file_paths.each do |from_file_path|
      to_locales.each do |to_locale|
        from_hash = {
          to_locale.to_s => YAML.load(File.read(from_file_path))[from_locale.to_s],
        }
        to_file_path = from_file_path.gsub(/#{from_locale}\.yml$/, "#{to_locale}.yml")
        to_hash = File.exist?(to_file_path) ? YAML.load(File.read(to_file_path)) : {}
        to_hash = deep_translate(from_hash, to_hash, from_locale, to_locale)
        File.write(to_file_path, YAML.dump(to_hash))
      end
    end
  end

  def self.deep_translate(from_hash, to_hash, from_locale, to_locale)
    ret = {}
    from_hash.each do |key, val|
      if val.is_a?(Hash)
        h = deep_translate(val, to_hash[key] || {}, from_locale, to_locale)
        ret[key] = Hash[h.sort]
      else
        md5_key = "#{key}_md5"
        md5 = ::Digest::MD5.hexdigest(val)
        if to_hash[md5_key].nil? || to_hash[md5_key] != md5
          ret[md5_key] = md5
          ret[key] = translate(val)
        else
          ret[md5_key] = to_hash[md5_key]
          ret[key] = to_hash[key]
        end
      end
    end
    ret
  end

  def self.translator
    @translator ||= ::Llm::Clients::AzureOpenAi.new
  end

  # don't need to test this method
  def self.translate(str)
    # DeepLのほうが望ましいがLLMで代用
    ret = self.translator.chat(parameters: {
      messages: [
        {
          role: "system",
          content: "You are an excellent translator. We translate strings sent by users into accurate English.\n" + \
            "We do not output any content other than the translation.\n" + \
            "Please keep the position and number of the new line code(\\n).\n" + \
            "Never omit the line feed code at the end of a sentence.",
        },
        {
          role: "user",
          content: str,
        },
      ],
    })
    translated = ret.dig("choices", 0, "message", "content")
    puts("#{str} => #{translated.green}")
    sleep(1)
    translated
  end
end
