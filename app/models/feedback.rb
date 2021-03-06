class Feedback < ActiveRecord::Base

  before_save :cannot_leave_feedback_on_your_own_listing

	VALID_DIRECTIONS = %w(buyer_to_seller seller_to_buyer)

	#Associations
	belongs_to :listing
	belongs_to :seller, :foreign_key => :seller_id, class_name: "User"
	belongs_to :buyer, :foreign_key => :buyer_id, class_name: "User"

  ##Proposed better solution to be reworked
  # belongs_to :author, :foreign_key => :author_id, :class_name => "User"
  # belongs_to :recipient, :foreign_key => :recipient_id, :class_name => "User"
  # belongs_to :transaction

  #Association validations
  validates_presence_of :seller
  validates_presence_of :buyer
  validates_presence_of :listing#, uniqueness: { scope: [:seller_id, :buyer_id, :direction], message: "Bob" }

  #Attribute validations
  validates_uniqueness_of :seller_id, :scope => :listing_id
	validates_presence_of :rating, message: "Your feedback must have a rating"
	validates_presence_of :direction, inclusion: { in: [true, false] }
	validates_presence_of :comment, message: "Your feedback must have a comment"
	validates_inclusion_of :direction, in: VALID_DIRECTIONS, allow_blank: false

	#Scopes
  scope :buyer_to_seller, ->{ where(direction: 'buyer_to_seller') }
  scope :seller_to_buyer, ->{ where(direction: 'seller_to_buyer') }
  scope :negative, -> { where(rating: false) }
  scope :positive, -> { where(rating: true) }
  scope :for_user, -> (user) {
    where("((feedbacks.user_id = ? AND feedbacks.direction = ?) OR (feedbacks.user_id = ? AND feedbacks.direction = ?))",
      user.id, true, user.id, false)
  }

  def positive?
    self.rating
  end

  def negative?
    !positive?
  end

  private

  def listing_must_be_complete
    errors.add(:id, "Feedback can't be created for this listing yet.") if self.listing && !self.listing.ready_for_feedback?
  end

  def cannot_leave_feedback_on_your_own_listing
    raise "You cannot leave feedback on your own listing." if self.seller.id == self.listing.user.id
  end

end
