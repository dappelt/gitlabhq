# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    def self.default_subscriptions_url
      ::Gitlab.dev_or_test_env? ? 'https://customers.stg.gitlab.com' : 'https://customers.gitlab.com'
    end

    def self.subscriptions_url
      ENV.fetch('CUSTOMER_PORTAL_URL', default_subscriptions_url)
    end

    def self.payment_form_url
      "#{self.subscriptions_url}/payment_forms/cc_validation"
    end

    def self.subscriptions_comparison_url
      'https://about.gitlab.com/pricing/gitlab-com/feature-comparison'
    end

    def self.subscriptions_graphql_url
      "#{self.subscriptions_url}/graphql"
    end

    def self.subscriptions_more_minutes_url
      "#{self.subscriptions_url}/buy_pipeline_minutes"
    end

    def self.subscriptions_more_storage_url
      "#{self.subscriptions_url}/buy_storage"
    end

    def self.subscriptions_manage_url
      "#{self.subscriptions_url}/subscriptions"
    end

    def self.subscriptions_plans_url
      "#{self.subscriptions_url}/plans"
    end

    def self.subscriptions_gitlab_plans_url
      "#{self.subscriptions_url}/gitlab_plans"
    end

    def self.subscriptions_instance_review_url
      "#{self.subscriptions_url}/instance_review"
    end

    def self.add_extra_seats_url(group_id)
      "#{self.subscriptions_url}/gitlab/namespaces/#{group_id}/extra_seats"
    end

    def self.upgrade_subscription_url(group_id, plan_id)
      "#{self.subscriptions_url}/gitlab/namespaces/#{group_id}/upgrade/#{plan_id}"
    end

    def self.renew_subscription_url(group_id)
      "#{self.subscriptions_url}/gitlab/namespaces/#{group_id}/renew"
    end

    def self.subscription_portal_admin_email
      ENV.fetch('SUBSCRIPTION_PORTAL_ADMIN_EMAIL', 'gl_com_api@gitlab.com')
    end

    def self.subscription_portal_admin_token
      ENV.fetch('SUBSCRIPTION_PORTAL_ADMIN_TOKEN', 'customer_admin_token')
    end
  end
end

Gitlab::SubscriptionPortal.prepend_mod
Gitlab::SubscriptionPortal::SUBSCRIPTIONS_URL = Gitlab::SubscriptionPortal.subscriptions_url.freeze
Gitlab::SubscriptionPortal::PAYMENT_FORM_URL = Gitlab::SubscriptionPortal.payment_form_url.freeze
