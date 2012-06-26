module NameTags
  def name_tag(*attrs)
    attrs.each do |attr|
      klass = attr.to_s.camelize.constantize

      define_method("#{attr}_name") do
        send(attr) ? send(attr).name : nil
      end

      define_method("#{attr}_name=") do |name|
        self.send("#{attr}=", name.present? ?
          (klass.name_is(name) || klass.new(:name => name))
          : nil)
      end
    end
  end
end