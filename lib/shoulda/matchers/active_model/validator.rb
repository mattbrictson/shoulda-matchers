module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class Validator
        include Helpers

        attr_writer :context, :expects_strict

        def initialize(record, attribute)
          @record = record
          @attribute = attribute
          @context = context
          @expects_strict = false
          reset
        end

        def reset
          @_validation_result = nil
          @captured_validation_exception = false
          @captured_range_error = false
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

        def messages
          if expects_strict?
            [validation_exception_message]
          else
            validation_error_messages
          end
        end

        def has_messages?
          messages.any?
        end

        def type_of_message_matched?
          expects_strict? == captured_validation_exception?
        end

        def captured_validation_exception?
          @captured_validation_exception
        end

        def captured_range_error?
          !!@captured_range_error
        end

        # TODO: Move to private
        def all_validation_errors
          validation_result[:all_validation_errors]
        end

        # TODO: Move to private
        def all_formatted_validation_error_messages
          format_validation_errors(all_validation_errors)
        end

        # TODO: Move to private
        def validation_error_messages
          validation_result[:validation_error_messages]
        end

        # TODO: Move to private
        def validation_exception_message
          validation_result[:validation_exception_message]
        end

        protected

        attr_reader :attribute, :context, :record

        private

        def expects_strict?
          @expects_strict
        end

        def validation_result
          @_validation_result ||= perform_validation
        end

        def perform_validation
          if context
            record.valid?(context)
          else
            record.valid?
          end

          all_validation_errors = record.errors.dup

          validation_error_messages =
            if record.errors.respond_to?(:[])
              record.errors[attribute]
            else
              record.errors.on(attribute)
            end

          {
            all_validation_errors: all_validation_errors,
            validation_error_messages: validation_error_messages,
            validation_exception_message: nil
          }
        rescue ::ActiveModel::StrictValidationFailed => exception
          @captured_validation_exception = true
          {
            all_validation_errors: nil,
            validation_error_messages: [],
            validation_exception_message: exception.message
          }
        end
      end
    end
  end
end
