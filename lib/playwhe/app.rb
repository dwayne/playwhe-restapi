module PlayWhe
  class App < Roda
    plugin :json
    plugin :status_handler

    route do |r|
      r.root do
        { message: 'Ok' }
      end

      r.on 'marks' do
        # GET /marks/1
        r.get Integer do |n|
          UseCases::GetMark.new(Models::Mark, n).call
        end

        # GET /marks
        r.get do
          UseCases::GetMarks.new(Models::Mark).call
        end
      end

      # GET /results
      r.get 'results' do
        begin
          UseCases::GetResults.new(Models::Result, r.params).call
        rescue UseCases::GetResults::ValidationError => e
          response.status = 400

          {
            message: 'Invalid parameters',
            errors: e.errors
          }
        end
      end

      r.on 'stats' do
        # GET /stats/mark-counts-for-date
        r.get 'mark-counts-for-date' do
          begin
            UseCases::GetMarkCountsForDate.new(Models::Result, r.params).call
          rescue UseCases::GetMarkCountsForDate::ValidationError => e
            response.status = 400

            {
              message: 'Invalid parameters',
              errors: e.errors
            }
          end
        end

        # GET /stats/mark-counts-for-weekday
        r.get 'mark-counts-for-weekday' do
          begin
            UseCases::GetMarkCountsForWeekday.new(Models::Result, r.params).call
          rescue UseCases::GetMarkCountsForWeekday::ValidationError => e
            response.status = 400

            {
              message: 'Invalid parameters',
              errors: e.errors
            }
          end
        end

        # GET /stats/marks-for-week
        r.get 'marks-for-week' do
          begin
            UseCases::GetMarksForWeek.new(Models::Result, r.params).call
          rescue UseCases::GetMarksForWeek::ValidationError => e
            response.status = 400

            {
              message: 'Invalid parameters',
              errors: e.errors
            }
          end
        end

        # GET /stats/marks-last-draw
        r.get 'marks-last-draw' do
          UseCases::GetMarksLastDraw.new(Models::Result).call
        end
      end

      # GET /suggestions
      r.get 'suggestions' do
        UseCases::GetSuggestions.new(Models::Result).call
      end
    end

    status_handler(404) do
      { message: 'Not found' }
    end
  end
end
