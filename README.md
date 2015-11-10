# Npmfed

Welcome to npmfed!
This gem is here to help you (fedora packager) to get npmjs modules quickly packaged and include it in fedora.
Aim of this project is to create tool similar to gofed which will guide packager of npm modules through the process of checking dependencies. Generating and building packages locally and submitting packages for package review.

## Installation

### Dependencies

 git, wget, koji, spec2scl


Install it yourself as:

    $ gem install npmfed

Or using fedora/centos repositories

    $ dnf install rubygem-npmfed
## Usage
npmfed check NPM MODULE NAME
npmfed download NPM MODULE NAME

For more information invoke npmfed help COMMAND


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/humaton/npmfed.
