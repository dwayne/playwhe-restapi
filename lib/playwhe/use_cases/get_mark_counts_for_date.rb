require 'dry-validation'

module PlayWhe
  module UseCases
    class GetMarkCountsForDate
      attr_reader :results_dataset, :opts

      SCHEMA = Dry::Validation.Form do
        optional(:year).maybe(:int?, gteq?: 1994)
        optional(:month).maybe(:int?, gteq?: 1, lteq?: 12)
        optional(:by_period).maybe(:bool?)
      end

      def initialize(results_dataset, opts)
        @results_dataset = results_dataset
        @opts = opts
      end

      def call
        result = SCHEMA.call(opts)

        if result.success?
          data = result.to_h

          # TODO: Consider taking DST into consideration.
          # See http://rpanachi.com/2016/07/04/ruby-is-time-to-talk-about-timezones
          current_time = Time.now.getlocal('-04:00')

          data[:year] = current_time.year unless data[:year]
          data[:by_period] = !!data[:by_period]

          ds = results_dataset.mark_counts_for_date(data[:year], data[:month], data[:by_period])

          generate_response(ds, data)
        else
          errors = result.errors(full: true).inject([]) { |errors, e| errors.concat e[1] }
          raise ValidationError.new(errors)
        end
      end

      class ValidationError < RuntimeError
        attr_reader :errors

        def initialize(errors)
          super
          @errors = errors
        end
      end

      private

      def generate_response(ds, data)
        response = {
          self: "/stats/mark-counts-for-date#{as_query(data)}"
        }

        values = ds.map(&:values)

        if data[:by_period]
          response[:counts] = group_by_period(values)
        else
          response[:counts] = values
        end

        response
      end

      def as_query(data)
        q = data.inject([]) { |terms, t| terms << "#{t[0]}=#{t[1]}" }.join('&')
        q = "?#{q}" unless q.empty?
      end

      def group_by_period(values)
        new_values = []

        current_new_value = nil
        last_number = nil

        values.each do |value|
          unless last_number == value[:number]
            new_values << current_new_value unless current_new_value.nil?

            last_number = value[:number]
            current_new_value = { number: value[:number], by_period: [], count: 0 }
          end

          current_new_value[:by_period] << { period: value[:period], count: value[:count] }
          current_new_value[:count] += value[:count]
        end

        new_values << current_new_value
        new_values
      end
    end
  end
end
