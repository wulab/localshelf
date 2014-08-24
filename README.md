# Localshelf

Ebook shelf for a group.

Localshelf allows users to manage and share their ebooks within a local network
through its web interface.

Only EPUB format is supported currently.

## Installation

Execute this line to install:

    $ gem install localshelf

## Usage

Create a bookshelf:

    $ localshelf init
    $ localshelf create OfficeShelf

Import ebooks to your bookshelf:

    $ localshelf import path/to/folder/

Share your bookshelf with others:

    $ localshelf server

Then check out http://<your-ip-address>:4567/ to see your collection.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/localshelf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
