# sqew (pronounced "skew")

sqew is a lightweight background processor. You start a single process that will act as a queue manager and will work multiple jobs concurrently.

sqew is short for "small queue" and is not meant to be an all scalable solution. If you need more management over worker processes or need to split it across multiple machines, you should use other background processors such as [Resque](https://github.com/defunkt/resque), [Sidekiq](https://github.com/mperham/sidekiq), and [Qu](https://github.com/bkeepers/qu).

sqew adopts a similiar API to make migrating to other background processors easier.

## Installation

Add this line to your application's Gemfile:

    gem sqew

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqew

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
