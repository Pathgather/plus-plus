module PlusPlus
  module Base
    def plus_plus(association, options={})
      self.after_create {
        self.plus_plus_on_create_or_destroy(association, options)
      }

      self.after_destroy {
        self.plus_plus_on_create_or_destroy(association, options)
      }
    end

    def plus_plus_on_updates(associations, options = {})
      self.after_update {
        dup = self.dup
        self.changes.each { |k, v| dup[k] = v.first }  # Create a 'snapshot' of what the model did look like
        associations.each do |association, columns|
          association_model = self.send(association)
          if association_model
            updates = {}
            columns.each do |column, value|
              options_to_iterate = value.is_a?(Hash) ? [value] : value
              options_to_iterate.each do |column_options|
                offset = if column_options[:value]
                  column_options[:value].is_a?(Proc) ? column_options[:value].call(self) : column_options[:value]
                else
                  1
                end

                if self.changes.include?(column_options[:column_changed])
                  if column_options[:switch]
                    old_association = dup.send(association)
                    update_old = true
                    update_new = true
                    if column_options[:switch].is_a?(Proc)
                      # if old_association satisfies condition then decrement
                      update_old = column_options[:switch].arity == 2 ? column_options[:switch].call(self, dup) : column_options[:switch].call(dup)
                      update_new = column_options[:switch].arity == 2 ? column_options[:switch].call(self, dup) : column_options[:switch].call(self)
                    end
                    old_association.update_columns(column => old_association.send(column) - offset) if update_old
                    updates[column] = association_model.send(column) + offset if update_new
                  elsif column_options[:decrement].call(dup) && column_options[:increment].call(self)
                    updates[column] = association_model.send(column) + offset
                  elsif column_options[:increment].call(dup) && column_options[:decrement].call(self)
                    updates[column] = association_model.send(column) - offset
                  end
                end
              end
            end
            association_model.send options[:update_method] || :update_columns, updates unless updates.blank?
          end
        end
      }
    end
  end

  module Model
    def plus_plus_on_create_or_destroy(association, options)
      association_model = self.send(association)
      raise "No association #{association}" unless association_model
      raise "No column specified" unless options[:column]
      return if options.has_key?(:if) && !self.instance_exec(&options[:if])
      return if options.has_key?(:unless) && self.instance_exec(&options[:unless])
      value = if options[:value]
        options[:value].respond_to?(:call) ? self.instance_exec(&options[:value]) : options[:value]
      else
        1
      end
      column  = options[:column]
      offset  = self.destroyed? ? -(value) : value
      new_val = association_model.send(column) + offset
      association_model.send options[:update_method] || :update_columns, {column => new_val}
    end
  end
end