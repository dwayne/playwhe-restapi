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
          results: results.sort { |r1, r2| r1[:date] <=> r2[:date] }
        }
      end
    end
  end
end
