# Raw Responses Compiler

## Installing Ruby 2.4.0 via RVM

1. Run `\curl -sSL https://get.rvm.io | bash` in terminal.
2. Once RVM installation complete, close and reopen terminal.
3. Run `rvm install 2.4.0` in terminal.
4. Run `rvm use 2.4.0 --default` in terminal.

## Install

1. `git clone https://github.com/OpenNOX/raw-responses-compiler.git`
2. `cd raw-responses-compiler`
3. `bundle install`
4. `cp config.example.yml config.yml`
5. Be sure to change the example configuration values to valid ones.

## Example Run

`./raw_responses_compiler.rb -s 2017-01-01 -e 2017-12-31 123`

## Help Text

```
usage: raw_responses_compiler.rb [options] PARENT_ORGANIZATION_ID

Specific options:
    -s, --start [DATE]               Remove records submitted before DATE.  (DATE FORMAT: YYYY-MM-DD)
    -e, --end [DATE]                 Remove records submitted after DATE.  (DATE FORMAT: YYYY-MM-DD)
    -h, --help                       Show this help message.
```
