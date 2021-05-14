# Shot Bot

Currently supports polling Walmart and Shoppers Drug Mart in Ontario, and notifying via SMTP and Twilio SMS.


## Getting started

Add a `config.yml` with:

```bash
cp config/config.example.yml config/config.yml
```

The config file defines the runners, groups, and notification on success or error.


Then to run:

```bash
bundle exec bot.rb
```

Work with:
```bash
bundle exec repl.rb
```

## Vaccine info

Find locations here:

https://covid-19.ontario.ca/vaccine-locations
