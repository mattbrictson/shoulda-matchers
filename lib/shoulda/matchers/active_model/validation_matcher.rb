module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class ValidationMatcher
        def initialize(attribute)
          @attribute = attribute
          @expects_strict = false
          @subject = nil
          @last_submatcher_run = nil
          @expected_message = nil
          @expects_custom_validation_message = false
        end

        def on(context)
          @context = context
          self
        end

        def strict
          @expects_strict = true
          self
        end

        def expects_strict?
          @expects_strict
        end

        def matches?(subject)
          @subject = subject
          false
        end

        def with_message(expected_message)
          if expected_message
            @expects_custom_validation_message = true
            @expected_message = expected_message
          end

          self
        end

        def expects_custom_validation_message?
          @expects_custom_validation_message
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def failure_message
          "#{overall_failure_message}".tap do |message|
            if submatcher_failure_message.present?
              message << "\n"
              message << Shoulda::Matchers.word_wrap(
                submatcher_failure_message,
                indent: 2
              )
            end
          end
        end

        def failure_message_when_negated
          "#{overall_failure_message_when_negated}".tap do |message|
            if submatcher_failure_message_when_negated.present?
              message << "\n"
              message << Shoulda::Matchers.word_wrap(
                submatcher_failure_message_when_negated,
                indent: 2
              )
            end
          end
        end

        protected

        attr_reader :attribute, :context, :subject, :last_submatcher_run

        def model
          subject.class
        end

        def allows_value_of(value, message = nil, &block)
          matcher = allow_value_matcher(value, message, &block)
          run_allow_or_disallow_matcher(matcher)
        end

        def disallows_value_of(value, message = nil, &block)
          matcher = disallow_value_matcher(value, message, &block)
          run_allow_or_disallow_matcher(matcher)
        end

        def allow_value_matcher(value, message = nil, &block)
          build_allow_or_disallow_value_matcher(
            matcher_class: AllowValueMatcher,
            value: value,
            message: message,
            &block
          )
        end

        def disallow_value_matcher(value, message = nil, &block)
          build_allow_or_disallow_value_matcher(
            matcher_class: DisallowValueMatcher,
            value: value,
            message: message,
            &block
          )
        end

        private

        def overall_failure_message
          Shoulda::Matchers.word_wrap(
            "#{model.name} did not properly #{description}."
          )
        end

        def overall_failure_message_when_negated
          Shoulda::Matchers.word_wrap(
            "Expected #{model.name} not to #{description}, but it did."
          )
        end

        def submatcher_failure_message
          last_submatcher_run.failure_message
        end

        def submatcher_failure_message_when_negated
          last_submatcher_run.failure_message_when_negated
        end

        def build_allow_or_disallow_value_matcher(args)
          matcher_class = args.fetch(:matcher_class)
          value = args.fetch(:value)
          message = args[:message]

          matcher = matcher_class.new(value).
            for(attribute).
            with_message(message).
            on(context).
            strict(expects_strict?)

          yield matcher if block_given?

          matcher
        end

        def run_allow_or_disallow_matcher(matcher)
          @last_submatcher_run = matcher
          matcher.matches?(subject)
        end
      end
    end
  end
end
