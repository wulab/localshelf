require 'thor'
require 'rack'
require 'socket'
require 'active_record'
require 'sqlite3'
require 'localshelf/bookshelf'
require 'localshelf/book'
require 'localshelf/format'

module Localshelf
  class CLI < Thor
    include Thor::Actions

    LOCALSHELF_HOME = File.expand_path("~/Localshelf")
    IP_ADDRESS      = Socket.ip_address_list.detect(&:ipv4_private?).ip_address

    desc "load_config", "Load Localshelf configs"
    def load_config
      abort(" ! Localshelf has not been initialized yet.") unless initialized?

      I18n.enforce_available_locales = false

      ActiveRecord::Base.establish_connection(
        adapter:  "sqlite3",
        database: File.join(LOCALSHELF_HOME, "Localshelf.sqlite3")
      )
    end

    desc "init", "Initialize Localshelf application"
    def init
      abort(" ! Localshelf has already been initialized.") if initialized?

      say("Initializing Localshelf at #{LOCALSHELF_HOME}")
      FileUtils.mkdir_p(LOCALSHELF_HOME)

      invoke :load_config, []

      ActiveRecord::Schema.define do
        create_table "bookshelves", force: true do |t|
          t.string   "name"
          t.string   "location"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
        end

        create_table "books", force: true do |t|
          t.integer  "bookshelf_id"
          t.string   "title"
          t.string   "language"
          t.string   "identifier"
          t.string   "creator"
          t.string   "cover_location"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
        end
        add_index "books", ["bookshelf_id"], name: "index_books_on_bookshelf_id"

        create_table "formats", force: true do |t|
          t.integer  "book_id"
          t.string   "checksum"
          t.string   "location"
          t.string   "original_location"
          t.integer  "size"
          t.string   "type"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
        end
        add_index "formats", ["book_id"], name: "index_formats_on_book_id"
        add_index "formats", ["checksum"], name: "index_formats_on_checksum", unique: true
      end
    end

    desc "create [NAME]", "Create a new bookshelf"
    def create(name="Default")
      invoke(:load_config, [])

      location = File.join(LOCALSHELF_HOME, name)
      say("Creating #{name} bookshelf at #{location}")

      bookshelf = Bookshelf.new(name: name, location: location)
      unless bookshelf.save
        abort(" ! Cannot create Bookshelf: #{bookshelf.errors.full_messages}")
      end
      bookshelf.construct!
    end

    # TODO Add support for wildcard argument
    desc "import FILES", "Import books to Localshelf"
    def import(files)
      invoke :load_config, []

      files        = File.expand_path(files)
      book_files   = files unless File.directory?(files)
      book_files ||= File.join(files, "*.{epub,EPUB}")  # TODO
      bookshelf    = Bookshelf.first  # TODO

      Dir[book_files].each do |file|
        filename = File.basename(file)

        if Format.exists?(original_location: file)
          say("Skipping #{filename}")
          next
        else
          say("Importing #{filename} to #{bookshelf.name}")
          format = Epub.new(original_location: file) # TODO
          unless format.save
            abort(" ! Cannot create Format: #{format.errors.full_messages}")
          end

          metadata = format.extract_metadata
          book     = bookshelf.books.find_by(identifier: metadata[:identifier])
          book   ||= bookshelf.books.build(metadata)
          book.formats << format

          unless book.save
            abort(" ! Cannot create Book: #{book.errors.full_messages}")
          end
          book.construct!
        end
      end
    end

    desc "server", "Share your bookshelf on http://#{IP_ADDRESS}:8080"
    def server
      app = Rack::Directory.new(LOCALSHELF_HOME)
      Rack::Handler::WEBrick.run(app)
    end

    private

      def initialized?
        Dir.exists?(LOCALSHELF_HOME)
      end

  end
end
