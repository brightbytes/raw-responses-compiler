require 'csv'
require 'write_xlsx'

class XlsxCompiler
  attr_reader :current_workbook

  def initialize
    @current_organization = nil
    @current_workbook     = nil
  end

  def compile!(csv_filepath, organization_name, group_name)
    close_previous_and_open_new_workbook(organization_name) if @current_organization.nil? || @current_organization != organization_name
    csv = CSV.read(csv_filepath, headers: true)
    if csv.size > 0
      worksheet = @current_workbook.add_worksheet(group_name)
      worksheet.write_row(0, 0, csv.headers.reject { |cell| remove_columns.include?(cell) }, @bold_text)
      csv.each_with_index do |row, i|
        worksheet.write_row(i + 1, 0, row.reject { |cell| remove_columns.include?(cell[0]) }.map { |cell| cell[1] })
      end
    end
  end

  private

  def sanitize_filename(file_name)
    file_name.gsub(/[\\\/:*?"<>|!]/, ' ')
  end

  def close_previous_and_open_new_workbook(organization_name)
    @current_workbook.close unless @current_workbook.nil?
    @current_organization = organization_name
    @current_workbook = WriteXLSX.new('./_ output _/' + sanitize_filename(organization_name) + '.xlsx')
    @bold_text = @current_workbook.add_format(bold: true)
  end

  def remove_columns
    ['Response ID', 'Campaign', 'IP Address']
  end
end
