# taken from woulda gem - http://github.com/seanhussey/woulda/tree/master

module AASM
  module SupportingClasses
    class Event
      def transition_list
        @transitions
      end
    end
  end
end

class Test::Unit::TestCase
  def self.should_act_as_state_machine(opts={})
    klass = model_class

    initial_state, states, events, db_column = get_options!([opts], :initial, :states, :events, :column)

    states ||= []
    events ||= {}
    db_column ||= :aasm_state

    context "A #{klass.name}" do

      should_have_db_column db_column, :type => :string

      should "include the ActsAsStateMachine module" do
        assert klass.included_modules.include?(AASM)
      end

      should "have an intital state of #{initial_state}" do
        assert_equal initial_state, klass.aasm_initial_state, "#{klass} does not have an initial state of #{initial_state}"
      end

      states.each do |state|
        should "include state #{state}" do
          assert klass.aasm_states.include?(state), "#{klass} does not include state #{state}"
        end
      end

      events.each do |event, transition|

        should "define an event #{event}" do
          assert klass.aasm_events.has_key?(event), "#{klass} does not define event #{event}"
        end

        to = transition[:to]
        from = transition[:from].is_a?(Symbol) ? [transition[:from]] : transition[:from]

        from.each do |from_state|
          should "transition to #{to} from #{from_state} on event #{event}" do
            assert_not_nil klass.aasm_events[event].transition_list.detect { |t| t.to == to && t.from == from_state }, "#{event} does not transition to #{to} from #{from_state}"
          end
        end

      end
    end
  end
end