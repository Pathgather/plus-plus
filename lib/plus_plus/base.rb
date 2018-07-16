module PlusPlus
  module Base
    def plus_plus(*args)
      options = args.extract_options!
      association, column = args

      after_create do
        plus_plus_on_create_or_destroy(association, column, options)
      end

      after_destroy do
        plus_plus_on_create_or_destroy(association, column, options)
      end
    end

    def plus_plus_on_change(*args)
      options = args.extract_options!
      association, column = args

      after_update do
        raise 'No :changed option specified' if options[:changed].nil?
        raise 'No :plus option specified' if options[:plus].nil?
        raise 'No :minus option specified' if options[:minus].nil?

        return unless changes.include?(options[:changed])

        # Create a 'snapshot' of what the model did look like
        dup = self.dup
        changes.each { |k, v| dup[k] = v.first }

        prev_satisfied_for_minus = plus_plus_satisfied_for?(dup,
                                                            options[:minus],
                                                            options[:changed])
        prev_satisfied_for_plus = plus_plus_satisfied_for?(dup,
                                                           options[:plus],
                                                           options[:changed])

        self_satisfied_for_minus = plus_plus_satisfied_for?(self,
                                                            options[:minus],
                                                            options[:changed])
        self_satisfied_for_plus = plus_plus_satisfied_for?(self,
                                                           options[:plus],
                                                           options[:changed])

        offset = if prev_satisfied_for_minus && self_satisfied_for_plus
                   plus_plus_value(options[:value])
                 elsif prev_satisfied_for_plus && self_satisfied_for_minus
                   -plus_plus_value(options[:value])
                 end

        if offset
          association_model = send(association)
          raise "No association #{association}" unless association_model

          plus_plus_update(options, association_model, column, offset)
        end
      end
    end
  end

  module Model
    def plus_plus_value(value)
      return 1 unless value

      if value.respond_to?(:call)
        instance_exec(&value)
      else
        value
      end
    end

    def plus_plus_satisfied_for?(object, action, changed)
      if action.respond_to?(:call)
        object.instance_exec(&action)
      else
        object.send(changed) == action
      end
    end

    def plus_plus_update(options, association_model, column_name, offset)
      association_model.with_lock do
        association_model.send(
          options.fetch(:update_method, :update_columns),
          column_name => association_model.send(column_name) + offset
        )
      end
    end

    def plus_plus_on_create_or_destroy(association, column, options)
      return if options.key?(:if) && !instance_exec(&options[:if])
      return if options.key?(:unless) && instance_exec(&options[:unless])

      association_model = send(association)
      raise "No association #{association}" unless association_model

      offset = if destroyed?
                 -plus_plus_value(options[:value])
               else
                 plus_plus_value(options[:value])
               end

      plus_plus_update(options, association_model, column, offset)
    end
  end
end
