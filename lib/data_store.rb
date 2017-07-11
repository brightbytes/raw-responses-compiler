require 'pg'

class DataStore
  attr_reader :results

  def initialize(connection_details)
    @connection = PG.connect(connection_details)
  end

  def query(query, org_id)
    query.gsub!('/* PARENT_ORGANIZATION_ID */', org_id)
    @results = @connection.exec(query)
  end

  def close
    @connection.close if @connection
  end
end
