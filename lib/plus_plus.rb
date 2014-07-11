require "plus_plus/base"

module PlusPlus
  def self.extended(model_class)
    return if model_class.respond_to? :plus_plus
    model_class.class_eval do
      extend Base
      include Model
    end
  end

  # Allow developers to `include` PlusPlus or `extend` it.
  def self.included(model_class)
    model_class.extend self
  end
end
