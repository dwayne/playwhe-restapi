module PlayWhe
  module UseCases
    class GetMarksLastDraw
      attr_reader :results_dataset

      def initialize(results_dataset)
        @results_dataset = results_dataset
      end

      def call
        results = (1..36).map do |number|
          results_dataset.first(number: number).values
        end

        {
          self: '/stats/marks-last-draw',
          results: results.sort { |a, b| compare(a, b) }
        }
      end

      private

      ASC_PERIOD = {
        'EM' => 0,
        'AM' => 1,
        'AN' => 2,
        'PM' => 3
      }

      def compare(a, b)
        if a[:date] == b[:date]
          ASC_PERIOD[a[:period]] <=> ASC_PERIOD[b[:period]]
        else
          a[:date] <=> b[:date]
        end
      end
    end
  end
end
