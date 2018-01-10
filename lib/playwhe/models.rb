module PlayWhe
  module Models
    class Mark < Sequel::Model
      # number, name
    end

    class Result < Sequel::Model
      # draw, date, period, number

      PERIOD_ASC = { 'EM' => 0, 'AM' => 1, 'AN' => 2, 'PM' => 3 }
      PERIOD_ASC_CASE = Sequel.case(PERIOD_ASC, 0, :period)

      PERIOD_DESC = { 'EM' => 3, 'AM' => 2, 'AN' => 1, 'PM' => 0 }
      PERIOD_DESC_CASE = Sequel.case(PERIOD_DESC, 0, :period)

      set_dataset dataset.order(Sequel.desc(:date), PERIOD_DESC_CASE)

      dataset_module do
        def after(date, period)
          filter { |r| (r.date =~ date) & (PERIOD_DESC_CASE < PERIOD_DESC.fetch(period)) }.
          or { |r| r.date > date }.
          reverse
        end

        def mark_counts_for_date(year = nil, month = nil, by_period = false)
          results = self
          results = results.filter(Sequel.extract(:year, :date) => year) if year
          results = results.filter(Sequel.extract(:month, :date) => month) if month

          mark_counts(results, by_period)
        end

        def mark_counts_for_weekday(weekday, by_period = false)
          results = filter(Sequel.function(:strftime, '%w', :date) => weekday.to_s)

          mark_counts(results, by_period)
        end

        def mark_counts(dataset = nil, by_period = false)
          results = dataset.nil? ? self : dataset
          results = Sequel.as(results.unordered, :results)

          marks_number = Sequel.qualify(:marks, :number)
          results_number = Sequel.qualify(:results, :number)

          join_opts = { number: :number }
          group_columns = [marks_number]

          select_columns = [marks_number]
          select_columns << Sequel.as(
            Sequel.function(:count, results_number),
            :count
          )

          order_columns = [marks_number]

          marks = Mark

          if by_period
            join_opts[:period] = :period

            marks_period = Sequel.qualify(:marks, :period)

            group_columns << marks_period
            select_columns << marks_period
            order_columns << Sequel.case(PERIOD_ASC, 0, marks_period)

            marks = marks_by_period
          end

          marks \
            .left_join(results, join_opts)
            .group(*group_columns)
            .select(*select_columns)
            .order(*order_columns)
        end

        def marks_by_period
          db.create_table!(:periods, temp: true) do
            String :period
          end
          ['EM', 'AM', 'AN', 'PM'].each do |period|
            db[:periods].insert([period])
          end

          Mark.cross_join(:periods).from_self(alias: :marks)
        end

        def in_date_range(date_range)
          filter(date: date_range).reverse
        end

        def lines_by_period
          db.create_table!(:lines, temp: true) do
            Integer :line
          end
          (1..9).each do |line|
            db[:lines].insert([line])
          end

          db.create_table!(:periods, temp: true) do
            String :period
          end
          ['EM', 'AM', 'AN', 'PM'].each do |period|
            db[:periods].insert([period])
          end

          db[:lines].cross_join(:periods).from_self(alias: :lines)
        end

        def numbers_lines
          db.create_table!(:numbers_lines, temp: true) do
            Integer :number
            Integer :line
          end
          (1..36).each do |number|
            db[:numbers_lines].insert([number, line(number)])
          end

          db[:numbers_lines]
        end

        def line(n)
          n < 10 ? n : line((n / 10) % 10 + n % 10)
        end
      end
    end
  end
end
