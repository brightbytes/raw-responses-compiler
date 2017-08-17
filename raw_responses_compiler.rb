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
DL_ATTEMPTS   = 5

puts 'Running initial query...'
ds = DataStore.new(CONFIG['database'])
ds.query(File.open('./query.sql').read, OPTIONS[:org_id], OPTIONS[:start_date], OPTIONS[:end_date])
row_count = ds.results.cmd_tuples

puts 'Web scraper logging in...'
ws = WebScraper.new
ws.login(CONFIG['web']['login'])

download_attempts = DL_ATTEMPTS
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
      sleep 5  # Prevent Rate Limiting
    end
    xc.compile!(csv_filepath, result['organization_name'], result['group_name'])
  rescue
    sleep 30  # Prevent Extreme Rate Limiting
    retry unless (download_attempts -= 1).zero?
    download_attempts = DL_ATTEMPTS
    print "ERROR: Unable to download #{result['organization_name']}'s #{result['group_name']} campaign after #{DL_ATTEMPTS} attempts. Moving on.\r\n"
    print "URL:   #{url}\r\n"
    $stdout.flush
  end
end
xc.current_workbook.close

ds.close

puts ''
