# sqew (pronounced "skew")

sqew is a lightweight background processor. You start a single process that will act as a queue manager and will work multiple jobs concurrently. sqew is short for "small queue" and is not meant to be an all-in-one scalable solution. sqew adopts a similiar API to make migrating to other background processors easy.

## When would sqew be a good fit for my project?

* You don't need to split workers across multiple machines.
* You don't want to manage multiple background worker processes, but you do want multiple jobs to run concurrently.
* You don't want to worry about threading issues.
* You don't want to worry about long running processes memory leaking.
* You don't care about the enqueueing or job forking performance.
* You don't need multiple queues (this may change soon).

If these don't fit the bill or you need more power, I recommend you try the great other great gems such as [Resque](https://github.com/defunkt/resque), [Sidekiq](https://github.com/mperham/sidekiq), and [Qu](https://github.com/bkeepers/qu).

## Rails Installation

Add this line to your application's Gemfile:

    gem sqew, :require "sqew/rails"

Add an initializer in `config/initializers/sqew.rb`

    Sqew.configure do |config|
      config.db = "#{Rails.root}/tmp/"
      config.server = "http://0.0.0.0:8884"
    end

The `db` config will be a directory where sqew will manage its databases, and the `server` config is what what the worker will connect at as well as where the application will post jobs to.

Once you have sqew configured, you can start the queue manager by running `rake sqew:work`. This will manage the queues, it'll act as a server where the application post jobs, and it will work the jobs as the arrive.

## Installation

Add this line to your application's Gemfile:

    gem sqew

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqew
    
## The Sqew Manager

The Sqew manager is a JSON API for inspecting the queue, pushing work onto the queue, and manipulating the queue and workers. Actions you can perform are:

    # enqueue a job
    # Sqew.push(TheJobClass, 1, 2, 3)
    POST /enqueue
      {"job":"TheJobClass", "args":[1, 2, 3]}
    
    # ping the server to programatically see if it is alive
    # Sqew.ping
    GET /ping
    
    # get the status of the queue, running jobs, failed jobs, and how many workers the server will use
    # Sqew.status
    GET /status
    
    # dynamically change the number of workers (processes) the manager will use
    # Sqew.workers = 10
    PUT /workers
      "10"
    
    # clear the entire queue
    # Sqew.clear
    DELETE /clear
    
    # clear just the failed jobs
    # Sqew.clear("failed")
    DELETE /clear
      failed
    
    # delete a specific job by id
    # Sqew.delete(11)
    DELETE /11
  
## Enqueuing jobs

From your application you will create jobs just like [Resque](https://github.com/defunkt/resque), [Sidekiq](https://github.com/mperham/sidekiq), and [Qu](https://github.com/bkeepers/qu) in the form of

    class MyJob
      def perform(arg1, arg2)
        # .. the job code
      end
    end

And the manager will receive the job and start working on it when it can. You can enqueue the job from Sqew:

    Sqew.push(MyJob, 1, 2)
    
If you're using Rails 4 you can enqueue the job by using the Rails queuing API:

    Rails.queue.push(MyJob, 1, 2)


## TODO Soon

* Reusable God/Bluepil/Monit config for managing the worker
* Javascript browser front-end for the manager
* Multiple queues with weight (possibly)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
