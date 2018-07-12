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

        changed = options[:changed]
        prev_satisfied_for_minus = if options[:minus].respond_to?(:call)
                                     dup.instance_exec(&options[:minus])
                                   else
                                     dup.send(changed) == options[:minus]
                                   end
        self_satisfied_for_plus = if options[:plus].respond_to?(:call)
                                    instance_exec(&options[:plus])
                                  else
                                    send(changed) == options[:plus]
                                  end
        self_satisfied_for_minus = if options[:minus].respond_to?(:call)
                                     instance_exec(&options[:minus])
                                   else
                                     send(changed) == options[:minus]
                                   end
        prev_satisfied_for_plus = if options[:plus].respond_to?(:call)
                                    dup.instance_exec(&options[:plus])
                                  else
                                    dup.send(changed) == options[:plus]
                                  end

        value = if options[:value]
                  if options[:value].respond_to?(:call)
                    instance_exec(&options[:value])
                  else
                    options[:value]
                  end
                else
                  1
                end

        offset = if prev_satisfied_for_minus && self_satisfied_for_plus
                   value
                 elsif prev_satisfied_for_plus && self_satisfied_for_minus
                   -value
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
    def plus_plus_update(options, association_model, column_name, offset)
      update_method = options.fetch(:update_method, :update_columns)
      values = { column_name => association_model.send(column_name) + offset }

      association_model.send(update_method, values)
    end

    def plus_plus_on_create_or_destroy(association, column, options)
      return if options.key?(:if) && !instance_exec(&options[:if])
      return if options.key?(:unless) && instance_exec(&options[:unless])

      association_model = send(association)
      raise "No association #{association}" unless association_model

      value = if options[:value]
                if options[:value].respond_to?(:call)
                  instance_exec(&options[:value])
                else
                  options[:value]
                end
              else
                1
              end

      offset = destroyed? ? -value : value

      plus_plus_update(options, association_model, column, offset)
    end
  end
end
