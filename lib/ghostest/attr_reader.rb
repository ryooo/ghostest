module AttrReader
  private
  def attr_reader(*args)
    args.each do |name|
      define_method name do
        return instance_variable_get "@#{name}"
      end
    end
    nil
  end
end
