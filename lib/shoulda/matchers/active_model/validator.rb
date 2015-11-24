module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class Validator
        include Helpers

        attr_writer :attribute, :context, :record

        def initialize
          reset
        end

        def reset
          @messages = nil
        end

        def strict=(strict)
          @strict = strict

          if strict
            extend StrictValidator
          end
        end

        def expected_messages_description(expected_message)
          "validation errors on :#{attribute} should have been present " +
            "and have included #{expected_message.inspect}"
        end

        def expected_messages_description_when_negated(expected_message)
          "validation errors on :#{attribute} included " +
            "#{expected_message.inspect} when it was not supposed to"
        end

        def actual_messages_description
          if has_messages?
            ".\n\nAll validation messages:\n#{pretty_error_messages(record)}"
          else
            ".\n\nNo validation messages were found on the record."
          end
        end

        def expected_message_from(attribute_message)
          attribute_message
        end

        def messages
          @messages ||= collect_messages
        end

        def formatted_messages
          messages
        end

        def has_messages?
          messages.any?
        end

        def captured_range_error?
          !!captured_range_error
        end

        protected

        attr_reader :attribute, :context, :strict, :record,
          :captured_range_error

        def collect_messages
          validation_errors
        end

        private

        def strict?
          !!@strict
        end

        def collect_errors_or_exceptions
          collect_messages
        end

        def validation_errors
          if context
            record.valid?(context)
          else
            record.valid?
          end

          if record.errors.respond_to?(:[])
            record.errors[attribute]
          else
            record.errors.on(attribute)
          end
        end

        def human_attribute_name
          record.class.human_attribute_name(attribute)
        end
      end
    end
  end
end
