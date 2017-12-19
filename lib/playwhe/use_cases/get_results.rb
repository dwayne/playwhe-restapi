require 'dry-validation'

module PlayWhe
  module UseCases
    class GetResults
      attr_reader :results_dataset, :opts

      SCHEMA = Dry::Validation.Form do
        optional(:year).maybe(:int?, gteq?: 1994)
        optional(:month).maybe(:int?, gteq?: 1, lteq?: 12)
        optional(:day).maybe(:int?, gteq?: 1, lteq?: 31)
        optional(:draw).maybe(:int?, gteq?: 1)
        optional(:period).maybe(:str?, format?: /\A(?:EM|AM|AN|PM)\Z/i)
        optional(:number).maybe(:int?, gteq?: 1, lteq?: 36)
        optional(:limit).maybe(:int?, gteq?: 1, lteq?: 50)
        optional(:page).maybe(:int?, gteq?: 1)
        optional(:order).maybe(:str?, format?: /\A(?:ASC|DESC)\Z/i)
      end

      DEFAULT_LIMIT = 12
      DEFAULT_PAGE = 1
      DEFAULT_ORDER = 'DESC'

      def initialize(results_dataset, opts)
        @results_dataset = results_dataset
        @opts = opts
      end

      def call
        result = SCHEMA.call(opts)

        if result.success?
          data = result.to_h

          data[:period] = data[:period].upcase if data[:period]
          data[:limit] = data.fetch(:limit, DEFAULT_LIMIT)
          data[:page] = data.fetch(:page, DEFAULT_PAGE)
          data[:order] = data.fetch(:order, DEFAULT_ORDER).upcase

          ds = results_dataset
          ds = ds.filter(Sequel.extract(:year, :date) => data[:year]) if data[:year]
          ds = ds.filter(Sequel.extract(:month, :date) => data[:month]) if data[:month]
          ds = ds.filter(Sequel.extract(:day, :date) => data[:day]) if data[:day]
          ds = ds.filter(draw: data[:draw]) if data[:draw]
          ds = ds.filter(period: data[:period]) if data[:period]
          ds = ds.filter(number: data[:number]) if data[:number]


          page = data[:page]
          total_results = ds.count
          total_pages = (total_results.to_f / data[:limit]).ceil

          ds = ds.reverse if data[:order] == 'ASC'
          offset = (page - 1) * data[:limit]
          ds = ds.limit(data[:limit]).offset(offset)

          generate_response(ds, data, page, total_pages, total_results)
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

      def generate_response(ds, data, page, total_pages, total_results)
        response = {
          self: "/results#{as_query(data)}",
          results: ds.map(&:values),
          page: page,
          total_pages: total_pages,
          total_results: total_results
        }

        has_prev = page > 1 && page <= total_pages
        has_next = page >= 1 && page < total_pages

        if has_prev
          extra_data = { page: page - 1 }
          response[:prev] = "/results#{as_query(data.merge(extra_data))}"
        end

        if has_next
          extra_data = { page: page + 1 }
          response[:next] = "/results#{as_query(data.merge(extra_data))}"
        end

        response
      end

      def as_query(data)
        q = data.inject([]) { |terms, t| terms << "#{t[0]}=#{t[1]}" }.join('&')
        q = "?#{q}" unless q.empty?
      end
    end
  end
end
