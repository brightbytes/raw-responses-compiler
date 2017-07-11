require 'mechanize'

class WebScraper
  def initialize
    @agent = Mechanize.new
    @agent.pluggable_parser.csv = Mechanize::Download
  end

  def login(login_details)
    page = @agent.get(login_details['url'])
    page = page.link_with(text: 'Please, login').click
    form = page.form_with(name: 'LoginForm')
    form.field_with(name: 'user[email]').value = login_details['username']
    form.field_with(name: 'user[password]').value = login_details['password']
    form.submit
  end

  def download(url, filepath)
    @agent.get(url).save(filepath)
  end
end
