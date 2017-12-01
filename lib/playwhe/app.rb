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
    end

    status_handler(404) do
      { message: 'Not found' }
    end
  end
end
