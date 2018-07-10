module PlusPlus
  module Base
    def plus_plus_warning_about_removal_update_method_from_options(options)
      return unless options[:update_method]

      puts <<-EOQ
      WARNING:
        `:update_method` option was removed from both `plus_plus` and
        `plus_plus_on_change` methods and has no longer effect. Please
        delete the option from your code as well.

        See more details here: https://github.com/Pathgather/plus-plus/pull/1.

        If you depend on the previous behaviour, please update your Gemfile:
        `gem 'plus-plus', github: 'pathgather/plus-plus', ref: '6fd9910'`.\n
      EOQ
    end

    def plus_plus(*args)
      options = args.extract_options!
      plus_plus_warning_about_removal_update_method_from_options(options)

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
      plus_plus_warning_about_removal_update_method_from_options(options)

      association, column = args

      after_update do
        raise 'No :changed option specified' if options[:changed].nil?
        raise 'No :plus option specified' if options[:plus].nil?
        raise 'No :minus option specified' if options[:minus].nil?

        association_model = send(association)
        raise "No association #{association}" unless association_model

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
          new_val = association_model.send(column) + offset
          association_model.update_columns(column => new_val)
        end
      end
    end
  end

  module Model
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

      new_val = association_model.send(column) + offset
      association_model.update_columns(column => new_val)
    end
  end
end
