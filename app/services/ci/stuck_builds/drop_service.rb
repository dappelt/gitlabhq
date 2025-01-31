# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropService
      include DropHelpers

      BUILD_PENDING_OUTDATED_TIMEOUT = 1.day
      BUILD_PENDING_STUCK_TIMEOUT = 1.hour
      BUILD_LOOKBACK = 5.days

      def execute
        Gitlab::AppLogger.info "#{self.class}: Cleaning stuck builds"

        drop(
          pending_builds(BUILD_PENDING_OUTDATED_TIMEOUT.ago),
          failure_reason: :stuck_or_timeout_failure
        )

        drop_stuck(
          pending_builds(BUILD_PENDING_STUCK_TIMEOUT.ago),
          failure_reason: :stuck_or_timeout_failure
        )
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      # We're adding the ordering clause by `created_at` and `project_id`
      # because we want to force the query planner to use the
      # `ci_builds_gitlab_monitor_metrics` index all the time.
      def pending_builds(timeout)
        if Feature.enabled?(:ci_new_query_for_pending_stuck_jobs)
          Ci::Build.pending.created_at_before(timeout).updated_at_before(timeout).order(created_at: :asc, project_id: :asc)
        else
          Ci::Build.pending.updated_before(lookback: BUILD_LOOKBACK.ago, timeout: timeout)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
