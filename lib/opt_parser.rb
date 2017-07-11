require 'optparse'

class OptParser
  def self.parse(args)
    options = {
      keep_csvs: false
    }

    raise ArgumentError, 'Must have numeric organization ID as last listed argument.' if args.empty? || /\A\d+|-h\Z/.match(args.last.strip).nil?

    options[:org_id] = args.last

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'usage: raw_responses_compiler.rb [options] PARENT_ORGANIZATION_ID'
      opts.separator ''
      opts.separator 'Specific options:'

      opts.on('-s', '--start [DATE]', String, 'Remove records submitted before DATE.  (DATE FORMAT: YYYY-MM-DD)') do |s|
        options[:start_date] = s
      end

      opts.on('-e', '--end [DATE]', String, 'Remove records submitted after DATE.  (DATE FORMAT: YYYY-MM-DD)') do |e|
        options[:end_date] = e
      end

      opts.on('-k', '--keep', "Keep source CSV files when script finishes?  (DEFAULT: #{options[:keep_csvs]})") do |k|
        options[:keep_csvs] = d
      end

      opts.on_tail("-h", "--help", "Show this help message.") do
        puts opts
        exit
      end
    end.parse!
    options
  end
end
