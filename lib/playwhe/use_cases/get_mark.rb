module PlayWhe
  module UseCases
    class GetMark
      attr_reader :marks_dataset, :n

      def initialize(marks_dataset, n)
        @marks_dataset = marks_dataset
        @n = n
      end

      def call
        marks_dataset[n].values if n >= 1 && n <= 36
      end
    end
  end
end
