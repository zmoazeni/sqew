# smallq

smallq is a lightweight background processor. You start a single process that will act as a queue manager and will work multiple jobs concurrently

smallq (as indicative of the name) is not meant to be an all encompassing scalable solution. If you need more management over worker processes or need to split it among multiple machines, it's recommend to use other background processors such as [Resque](https://github.com/defunkt/resque), [Sidekiq](https://github.com/mperham/sidekiq), and [Qu](https://github.com/bkeepers/qu).

smallq adopts a similiar API to make migrating to other background processors easier.

## Installation

Add this line to your application's Gemfile:

    gem 'smallq'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smallq

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
