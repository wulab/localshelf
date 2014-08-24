module Localshelf
  class Book < ActiveRecord::Base
    belongs_to :bookshelf
    has_many :formats
    validates :title, :identifier, presence: true

    def target_location
      File.join(bookshelf.location, identifier)
    end

    def construct!
      return false unless persisted? && valid?
      FileUtils.mkdir_p(target_location)
      formats.to_a.count(&:construct!)
    end
  end
end
