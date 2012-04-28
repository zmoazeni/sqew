module Sqew
  module Backend
    class LevelDB < Qu::Backend::Base
      alias_method :db_path, :connection
      
      def queue
        @queue ||= ::LevelDB::DB.new("#{db_path}/queue.ldb")
      end
      
      def enqueue(payload)
        queue[Time.now.to_f.to_s] = MultiJson.dump(klass:payload.klass.to_s, args:payload.args)
      end
      
      def reserve(_, options = {block:false})
        loop do
          logger.debug { "Reserving job" }

          if raw = queue.first
            id, job = raw
            queue.delete(id)
            return Qu::Payload.new(MultiJson.load(job).update(id:id))
          end

          if options[:block]
            sleep @poll_frequency
          else
            break
          end
        end
      end

      def completed(*)
      end

      def failed(*)
      end

      def release(*)
      end

      def register_worker(*)
      end

      def unregister_worker(*)
      end
    end
  end
end
