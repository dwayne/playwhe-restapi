require 'json'

require './models'

module PlayWheHelper
  def results
    validate_and_parse!

    where_date = []
    where_date << ["strftime('%Y', date) = ?", params[:year]] if params[:year]
    where_date << ["strftime('%m', date) = ?", params[:month]] if params[:month]
    where_date << ["strftime('%d', date) = ?", params[:day]] if params[:day]

    r =
      if where_date.empty?
        Result.all
      else
        where_clause = where_date.map { |p| p[0] }.join(' AND ')
        values = where_date.map { |p| p[1] }

        Result.find_by_sql [<<-SQL].concat values
          SELECT * FROM results WHERE #{where_clause}
        SQL
      end

    r = r.all(draw: params[:draw]) if params[:draw]
    r = r.all(period: params[:period]) if params[:period]
    r = r.all(number: params[:number]) if params[:number]

    r.all(limit: params[:limit], offset: params[:offset], order: [ params[:order] ])
  end

  def validate_and_parse!
    if params[:year]
      pass unless params[:year] =~ /^([1-9]\d{3})$/
    end

    if params[:month]
      if params[:month] =~ /^([1-9]|10|11|12)$/
        params[:month] = sprintf("%02d", params[:month])
      else
        pass
      end
    end

    if params[:day]
      if params[:day] =~ /^([1-9]|[1-2][0-9]|30|31)$/
        params[:day] = sprintf("%02d", params[:day])
      else
        pass
      end
    end

    if params[:draw]
      pass unless params[:draw] =~ /^([1-9]\d*)$/
    end

    if params[:period]
      if params[:period] =~ /^(EM|AM|AN|PM)$/i
        params[:period] = params[:period].upcase
      else
        pass
      end
    end

    if params[:number]
      pass unless params[:number] =~ /^([1-9]|[1-2][0-9]|3[0-6])$/
    end

    if params[:limit]
      if params[:limit] =~ /^(\d+)$/
        params[:limit] = params[:limit].to_i
      else
        halt_with_invalid_param(:limit)
      end
    else
      params[:limit] = 10
    end

    if params[:offset]
      if params[:offset] =~ /^(\d+)$/
        params[:offset] = params[:offset].to_i
      else
        halt_with_invalid_param(:offset)
      end
    else
      params[:offset] = 0
    end

    if params[:order]
      if params[:order].upcase =~ /^(ASC|DESC)$/
        params[:order] = params[:order].upcase == "ASC" ? :draw.asc : :draw.desc
      else
        halt_with_invalid_param(:order)
      end
    else
      params[:order] = :draw.desc
    end
  end

  def halt_with_invalid_param(name)
    halt 400, {message: "Invalid parameter, #{name}"}.to_json
  end
end
