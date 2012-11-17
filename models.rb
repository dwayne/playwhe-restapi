require 'data_mapper'

class Mark
  include DataMapper::Resource

  property :number, Serial
  property :name,   String, required: true
end

class Result
  include DataMapper::Resource

  property :draw,   Serial
  property :date,   Date,    required: true
  property :period, Integer, required: true
  property :number, Integer, required: true
end

DataMapper.finalize
