module Documents::StateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :status do
      state :on_revision, initial: true
      state :approved
      state :revised
      state :obsolete

      event :revise, before: :retrieve_revision_url do
        transitions to: :revised, from: :on_revision
      end
      
      event :approve, after: :mark_related_as_obsolete do
        transitions to: :approved, from: :revised
      end
      
      event :reject, before: :remove_revision_url do
        transitions to: :on_revision, from: [:revised]
      end
      
      event :mark_as_obsolete do
        transitions to: :obsolete, from: :approved
      end
      
      event :reset_status do
        transitions to: :on_revision, from: :approved
      end
    end
  end
end
