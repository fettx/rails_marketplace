class Listing < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :watches
	has_many :watchers, -> { uniq }, :through => :watches

	def self.search(search)
	  where("title ILIKE ?", "%#{search}%") 
	end


end
