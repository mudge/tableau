This is a fork of [Asim Aslam's Tableau](http://github.com/asim/tableau): a private pastie to use with friends and colleagues.

It is a very spartan pastie application with rudimentary versioning of pastes (ala [Gist](http://gist.github.com/)).

It has the following dependencies:

* [sinatra](http://www.sinatrarb.com)
* [sequel](http://sequel.rubyforge.org/)
* [open4](http://raa.ruby-lang.org/project/open4/) (required by [albino](http://github.com/github/albino))
* [pygments](http://pygments.org/) (and therefore [Python](http://www.python.org/))

To create the database and necessary tables, simply run `rake migrate` then fire up the application with `rackup` and access it at [http://localhost:9292](http://localhost:9292).

