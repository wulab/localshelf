require 'epubinfo'

module Localshelf
  class Format < ActiveRecord::Base
    belongs_to :book
    validates :original_location, presence: true
    validate :original_location_exists
    before_create :set_metadata

    def target_location
      target_extname  = File.extname(original_location).downcase
      target_filename = [checksum, target_extname].join
      File.join(book.bookshelf.location, book.identifier, target_filename)
    end

    def construct!
      return false unless persisted? && valid?
      return false if File.exists?(target_location)
      FileUtils.cp(original_location, target_location)
      update(location: target_location)
    end

    private

      def original_location_exists
        unless File.exists?(original_location)
          errors.add(:original_location, "doesn't exist")
        end
      end

      def set_metadata
        self.checksum ||= "%x" % ( Integer( `cksum '#{original_location}'`[/^\d+/] ) & 0xffffffff )
        self.size     ||= File.size(original_location)
      end
  end

  class Epub < Format
    validates :original_location, format: { with: /epub\z/i }

    def extract_metadata
      {
        title:      parser.titles.first,
        language:   parser.languages.first,
        identifier: parser.identifiers.first.identifier.gsub(/\D+/, ""),
        creator:    parser.creators.map(&:name).join(", ")
      }
    end

    def construct!
      super

      # TODO
      return unless parser.cover
      target_extname  = File.extname(parser.cover.original_file_name).downcase
      target_location = File.join(
                          book.bookshelf.location,
                          book.identifier,
                          ["cover", target_extname].join
                        )
      unless File.exists?(target_location)
        parser.cover.tempfile { |f| FileUtils.cp(f.path, target_location) }
        book.update(cover_location: target_location)
      end
    end

    private

      def parser
        return @_parser if @_parser
        raise "No location" unless original_location?
        EPUBInfo.get(original_location)
      end
  end

  class Pdf < Format
  end
end
