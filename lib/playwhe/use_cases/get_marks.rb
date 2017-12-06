module PlayWhe
  module UseCases
    class GetMarks
      attr_reader :marks_dataset

      def initialize(marks_dataset)
        @marks_dataset = marks_dataset
      end

      def call
        marks_dataset.map(&:values)
      end
    end
  end
end
