module PlayWhe
  module Models
    class Mark < Sequel::Model
      # number, name
    end

    class Result < Sequel::Model
      # draw, date, period, number

      PERIOD_DESC = { 'EM' => 3, 'AM' => 2, 'AN' => 1, 'PM' => 0 }
      PERIOD_DESC_CASE = Sequel.case(PERIOD_DESC, 0, :period)

      set_dataset dataset.order(Sequel.desc(:date), PERIOD_DESC_CASE)

      dataset_module do
        def after(date, period)
          filter { |r| (r.date =~ date) & (PERIOD_DESC_CASE < PERIOD_DESC.fetch(period)) }.
          or { |r| r.date > date }.
          reverse
        end
      end
    end
  end
end
