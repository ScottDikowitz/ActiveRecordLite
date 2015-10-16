class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}")
      end
      name_normal = name
      name_changed = name.to_s + "="
      name_changed = name_changed.to_sym

      name_sym = name.to_s
      define_method(name_changed) do |value|

        instance_variable_set("@#{name}", value)
      end
    end
  end
end
