module Localshelf
  class Bookshelf < ActiveRecord::Base
    has_many :books
    validates :name, :location, presence: true, uniqueness: true

    def target_location
      location
    end

    def construct!
      return false unless persisted? && valid?
      FileUtils.mkdir_p(target_location)
      books.to_a.count(&:construct!)
    end
  end
end
