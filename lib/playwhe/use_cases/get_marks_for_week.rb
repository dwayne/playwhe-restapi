require 'dry-validation'

module PlayWhe
  module UseCases
    class GetMarksForWeek
      attr_reader :results_dataset, :opts

      SCHEMA = Dry::Validation.Form do
        optional(:offset).maybe(:int?, gteq?: 0, lteq?: 52)
      end

      DEFAULT_OFFSET = 1

      def initialize(results_dataset, opts)
        @results_dataset = results_dataset
        @opts = opts
      end

      def call
        result = SCHEMA.call(opts)

        if result.success?
          data = result.to_h

          data[:offset] = data.fetch(:offset, DEFAULT_OFFSET)

          week_range = prev_week_range_from_now(data[:offset])
          ds = results_dataset.in_date_range(week_range)

          generate_response(ds, data, week_range)
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

      def prev_week_range(time, n)
        offset = 1 - time.wday

        monday = time.to_date + (offset - n * 7)
        saturday = monday + 5

        monday..saturday
      end

      def prev_week_range_from_now(n)
        prev_week_range(now, n)
      end

      def now
        # TODO: Consider taking DST into consideration.
        # See http://rpanachi.com/2016/07/04/ruby-is-time-to-talk-about-timezones
        @_now ||= Time.now.getlocal('-04:00')
      end

      DATE_FORMAT = '%Y-%m-%d'

      def generate_response(ds, data, week_range)
        values = ds.map(&:values)

        {
          self: "/stats/marks-for-week?offset=#{data[:offset]}",
          start_date: week_range.first.strftime(DATE_FORMAT),
          end_date: week_range.last.strftime(DATE_FORMAT),
          same_day_of_week: same_day_of_week(data[:offset]).strftime(DATE_FORMAT),
          results: fill_with_blanks(values, week_range)
        }
      end

      def same_day_of_week(n)
        now.to_date - n * 7
      end

      def fill_with_blanks(values, week_range)
        new_results = []

        len = values.length
        index = 0
        week_range.each do |date|
          current_date = date.strftime(DATE_FORMAT)
          current_record = { date: current_date, by_period: [] }

          ['EM', 'AM', 'AN', 'PM'].each do |period|
            if index < len && values[index][:date] == current_date && values[index][:period] == period
              current_record[:by_period] << {
                draw: values[index][:draw],
                date: current_date,
                period: period,
                number: values[index][:number]
              }

              index += 1
            else
              current_record[:by_period] << {
                draw: nil,
                date: current_date,
                period: period,
                number: nil
              }
            end
          end

          new_results << current_record
        end

        new_results
      end
    end
  end
end
