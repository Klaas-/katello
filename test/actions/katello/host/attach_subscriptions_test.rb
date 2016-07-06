require 'katello_test_helper'

module Katello::Host
  class AttachSubscriptionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryGirl.create(:host, :with_subscription)
      @pool = katello_pools(:pool_one)
    end

    describe 'attach subscriptions' do
      let(:action_class) { ::Actions::Katello::Host::AttachSubscriptions }

      it 'plans' do
        action = create_action action_class
        action.expects(:action_subject).with(@host)

        pools_with_quantities = [::Katello::PoolWithQuantities.new(@pool, [1, 2])]

        plan_action action, @host, pools_with_quantities

        assert_action_planed_with action, Actions::Candlepin::Consumer::AttachSubscription, :uuid => @host.subscription_facet.uuid,
                                  :quantity => 1, :pool_uuid => @pool.cp_id
        assert_action_planed_with action, Actions::Candlepin::Consumer::AttachSubscription, :uuid => @host.subscription_facet.uuid,
                                          :quantity => 2, :pool_uuid => @pool.cp_id
      end
    end
  end
end