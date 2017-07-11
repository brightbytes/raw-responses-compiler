#!/usr/bin/env ruby

require 'yaml'

require './lib/helpers.rb'
require './lib/opt_parser'
require './lib/data_store'
require './lib/web_scraper'
require './lib/xlsx_compiler'

CONFIG        = YAML.load_file('config.yml')
OPTIONS       = OptParser.parse(ARGV)
CSV_DIRECTORY = './csv/'

puts 'Running initial query...'
ds = DataStore.new(CONFIG['database'])
ds.query(File.open('./query.sql').read, OPTIONS[:org_id])
row_count = ds.results.cmd_tuples

puts 'Web scraper logging in...'
ws = WebScraper.new
ws.login(CONFIG['web']['login'])

xc = XlsxCompiler.new
ds.results.each_with_index do |result, i|
  print "Downloading and processing CSV #{i + 1} of #{row_count} (#{(((i + 1).to_f / row_count.to_f) * 100).round(0)}%)\r"
  $stdout.flush
  url = url_template_helper(
    CONFIG['web']['download']['url_template'],
    result['id'],
    OPTIONS[:start_date],
    OPTIONS[:end_date]
  )
  csv_filepath = CSV_DIRECTORY + result['id'] + '.csv'
  begin
    unless File.exist?(csv_filepath)
      ws.download(url, csv_filepath)
    end
    xc.compile!(csv_filepath, result['organization_name'], result['group_name'])
  rescue
    print "ERROR: Unable to download #{result['organization_name']}'s #{result['group_name']} campaign.\r\n"
    $stdout.flush
  end
  sleep 5  # Prevent Rate Limiting
end
xc.current_workbook.close

ds.close

unless OPTIONS[:keep_csvs]
  Dir.glob('./csv/*.csv') do |file|
    File.delete(file)
  end
end

puts ''
