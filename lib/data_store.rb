require 'pg'

require './lib/helpers'

class DataStore
  attr_reader :results

  def initialize(connection_details)
    @connection = PG.connect(connection_details)
  end

  def query(query, org_id, start_date, end_date)
    query.gsub!('/* PARENT_ORGANIZATION_ID */', org_id)
    query.gsub!('/* DATE_FILTER_PLACEHOLDER */', query_date_filter_helper(start_date, end_date))
    @results = @connection.exec(query)
  end

  def close
    @connection.close if @connection
  end
end
