# frozen_string_literal: true

# This is a copy of https://github.com/mperham/sidekiq/blob/32c55e31659a1e6bd42f98334cca5eef2863de8d/lib/sidekiq/scheduled.rb#L11-L34
#
# It effectively reverts
# https://github.com/mperham/sidekiq/commit/9b75467b33759888753191413eddbc15c37a219e
# because we observe that the extra ZREMs caused by this change can lead to high
# CPU usage on Redis at peak times:
# https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1179
#
module Gitlab
  class SidekiqEnq
    def enqueue_jobs(now = Time.now.to_f.to_s, sorted_sets = Sidekiq::Scheduled::SETS)
      # A job's "score" in Redis is the time at which it should be processed.
      # Just check Redis for the set of jobs with a timestamp before now.
      Sidekiq.redis do |conn|
        sorted_sets.each do |sorted_set|
          # Get the next item in the queue if it's score (time to execute) is <= now.
          # We need to go through the list one at a time to reduce the risk of something
          # going wrong between the time jobs are popped from the scheduled queue and when
          # they are pushed onto a work queue and losing the jobs.
          while (job = conn.zrangebyscore(sorted_set, "-inf", now, limit: [0, 1]).first)

            # Pop item off the queue and add it to the work queue. If the job can't be popped from
            # the queue, it's because another process already popped it so we can move on to the
            # next one.
            if conn.zrem(sorted_set, job)
              Sidekiq::Client.push(Sidekiq.load_json(job))
              Sidekiq.logger.debug { "enqueued #{sorted_set}: #{job}" }
            end
          end
        end
      end
    end
  end
end
