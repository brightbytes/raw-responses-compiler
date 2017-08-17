require 'uri'

def query_date_filter_helper(start_date, end_date)
  if start_date && end_date.nil?
    "AND      qr.submitted_at > '#{start_date}'"
  elsif end_date && start_date.nil?
    "AND      qr.submitted_at < '#{end_date}'"
  elsif start_date && end_date
    "AND      qr.submitted_at BETWEEN '#{start_date}' AND '#{end_date}'"
  else
    ""
  end
end

def url_template_helper(template, id, start_date, end_date)
  date_format = '%b %m, %Y'
  url_params = '?'
  if start_date
    start_date = URI.encode(Date.parse(start_date)
                                .strftime(date_format)
                                .to_s)
    url_params += 'start_date=:start_date'
  end
  if end_date
    end_date = URI.encode(Date.parse(end_date)
                              .strftime(date_format)
                              .to_s)
    url_params += '&' if url_params != '?'
    url_params += 'end_date=:end_date'
  end
  url = (template + url_params).sub(':id', id)
  url.sub!(':start_date', start_date) unless start_date.nil?
  url.sub!(':end_date', end_date) unless end_date.nil?
  url
end
