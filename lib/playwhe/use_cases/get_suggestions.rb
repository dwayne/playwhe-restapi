require 'set'

module PlayWhe
  module UseCases
    class GetSuggestions
      attr_reader :results_dataset, :prng

      def initialize(results_dataset, prng = nil)
        @results_dataset = results_dataset
        @prng = prng.nil? ? default_prng : prng
      end

      def call
        ds = mark_data.from_self.order(:prob)
        ds_reversed = ds.reverse
        limit = 6
        take = 3

        unlikely_marks = PERIODS.map do |period|
          { period: period, picks: picks(ds, period, limit, take) }
        end

        all_unlikely_marks = combine(unlikely_marks)

        likely_marks = PERIODS.map do |period|
          { period: period, picks: picks(ds_reversed, period, limit, take) }
        end

        all_likely_marks = combine(likely_marks)

        ds = line_data.from_self.order(:prob)
        ds_reversed = ds.reverse
        limit = 4
        take = 2

        unlikely_lines = PERIODS.map do |period|
          { period: period, picks: picks(ds, period, limit, take) }
        end

        all_unlikely_lines = combine(unlikely_lines)

        likely_lines = PERIODS.map do |period|
          { period: period, picks: picks(ds_reversed, period, limit, take) }
        end

        all_likely_lines = combine(likely_lines)

        {
          self: '/suggestions',
          unlikely_marks: unlikely_marks,
          all_unlikely_marks: all_unlikely_marks,
          likely_marks: likely_marks,
          all_likely_marks: all_likely_marks,
          unlikely_lines: unlikely_lines,
          all_unlikely_lines: all_unlikely_lines,
          likely_lines: likely_lines,
          all_likely_lines: all_likely_lines
        }
      end

      private

      PERIODS = %w(EM AM AN PM)

      def combine(data_by_period)
        data = SortedSet.new

        data_by_period.each { |r| data.merge r[:picks] }

        data.to_a
      end

      def default_prng
        Random.new(now.year * now.month * now.day)
      end

      def mark_data
        a = mark_probs_all_time.from_self(alias: :a)
        b = Sequel.as(mark_probs_by_month, :b)
        c = Sequel.as(mark_probs_by_weekday, :c)

        a_number = Sequel.qualify(:a, :number)
        a_period = Sequel.qualify(:a, :period)
        a_prob = Sequel.qualify(:a, :prob)

        b_number = Sequel.qualify(:b, :number)
        b_period = Sequel.qualify(:b, :period)
        b_prob = Sequel.qualify(:b, :prob)

        c_number = Sequel.qualify(:c, :number)
        c_period = Sequel.qualify(:c, :period)
        c_prob = Sequel.qualify(:c, :prob)

        prob = Sequel.as(a_prob * b_prob * c_prob, :prob)
        select_columns = [a_number, a_period, prob]

        a \
          .inner_join(b, b_number => a_number, b_period => a_period)
          .inner_join(c, c_number => a_number, c_period => a_period)
          .select(*select_columns)
          .order(:prob)
      end

      def mark_probs_all_time
        # For all time, determine how many times the number, n, has played and
        # group it by the period. Use that to determine the probability that n
        # will play for a given period.

        ds = results_dataset.mark_counts_for_date(nil, nil, true)

        probs ds
      end

      def mark_probs_by_month
        # For all time, determine how many times the number, n, has played in a
        # given month (Jan-Dec) for a given period.

        month = now.month
        ds = results_dataset.mark_counts_for_date(nil, month, true)

        probs ds
      end

      def mark_probs_by_weekday
        # For all time, determine how many times the number, n, has played on a
        # given day of the week (Mon-Sat) for a given period.

        wday = now.wday
        ds = results_dataset.mark_counts_for_weekday(wday, true)

        probs ds
      end

      def line_data
        a = line_probs_all_time.from_self(alias: :a)
        b = Sequel.as(line_probs_by_month, :b)
        c = Sequel.as(line_probs_by_weekday, :c)

        a_number = Sequel.qualify(:a, :number)
        a_period = Sequel.qualify(:a, :period)
        a_prob = Sequel.qualify(:a, :prob)

        b_number = Sequel.qualify(:b, :number)
        b_period = Sequel.qualify(:b, :period)
        b_prob = Sequel.qualify(:b, :prob)

        c_number = Sequel.qualify(:c, :number)
        c_period = Sequel.qualify(:c, :period)
        c_prob = Sequel.qualify(:c, :prob)

        prob = Sequel.as(a_prob * b_prob * c_prob, :prob)
        select_columns = [a_number, a_period, prob]

        a \
          .inner_join(b, b_number => a_number, b_period => a_period)
          .inner_join(c, c_number => a_number, c_period => a_period)
          .select(*select_columns)
          .order(:prob)
      end

      def line_probs_all_time
        # For all time, determine how many times the line, n, has played and
        # group it by the period. Use that to determine the probability that n
        # will play for a given period.

        ds = results_dataset.mark_counts_for_date(nil, nil, true)

        line_probs ds
      end

      def line_probs_by_month
        # For all time, determine how many times the line, n, has played in a
        # given month (Jan-Dec) for a given period.

        month = now.month
        ds = results_dataset.mark_counts_for_date(nil, month, true)

        line_probs ds
      end

      def line_probs_by_weekday
        # For all time, determine how many times the line, n, has played on a
        # given day of the week (Mon-Sat) for a given period.

        wday = now.wday
        ds = results_dataset.mark_counts_for_weekday(wday, true)

        line_probs ds
      end

      def line_probs(ds)
        results_period = Sequel.qualify(:results, :period)
        results_count = Sequel.qualify(:results, :count)

        probs ds \
          .from_self(alias: :results)
          .inner_join(results_dataset.numbers_lines, number: :number)
          .group(:line, results_period)
          .select(
            Sequel.as(:line, :number),
            results_period,
            Sequel.as(
              Sequel.function(:sum, results_count),
              :count
            )
          )
      end

      def probs(ds)
        total = ds.sum(:count)
        ds.from_self.select do |r|
          [r.number, r.period, (r.count / total.to_f).as(:prob)]
        end
      end

      def now
        # TODO: Consider taking DST into consideration.
        # See http://rpanachi.com/2016/07/04/ruby-is-time-to-talk-about-timezones
        @_now ||= Time.now.getlocal('-04:00')
      end

      def picks(ds, period, limit, take)
        ds \
          .filter(period: period)
          .limit(limit)
          .all
          .shuffle(random: prng)
          .take(take)
          .map(&:number)
          .sort
      end
    end
  end
end
