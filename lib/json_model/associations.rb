require 'active_support/inflector'

module JsonModel
  module Associations
    def initialize(attrs = {})
      super(attrs)

      attrs = symbolize_keys(attrs)

      puts " "
      puts "Self #{self}"
      puts " "
      self.class.associations.each do |a, info|
        puts "initialize >>>> #{a} /// #{info}"
        send("#{a}=", [])
        next if !attrs.include?(a)

        if info[:class].nil?
          namespace = self.class.to_s.split("::")
          namespace.pop
          namespace.push(ActiveSupport::Inflector.classify(a))

          klass = namespace.join("::")
          klass = ActiveSupport::Inflector.constantize(klass)
        else
          klass = info[:class]
        end

        attrs[a].each do |assoc|
          puts "assoc >>>> #{assoc} "

          if assoc.is_a?(Array)
            assoc = assoc[1]
          end

          attrib = send(a)
          instance = klass.new(assoc)
          instance.instance_variable_set("@parent", self)
          attrib.push(instance)

        end
      end
    end

    # Converts the current object to a hash with attribute names as keys
    # and the values of the attributes as values
    #
    def as_json
      attrs = super
      self.class.associations.each do |name, info|

        puts "as_json >>>> #{name} /// #{info}"

        attrs[name] = []

        arr = send(name)
        next if arr.nil?

        arr.each do |object|
          attrs[name].push(object.as_json) unless object.nil?
        end
      end
      attrs
    end

    module ClassMethods
      def associations
        @associations ||= {}
      end

      def has_many(association, params = {})
        puts "has_many >>>> #{association} || #{self}"
        associations.store(association, params)
        self.send(:attr_accessor, association)
      end
    end
  end
end