echo-collection-tool
====================
This repo holds some tools I use to slice and dice ECHO collections looking for data I am interested in


_retrieveEchoCollections.rb_

Builds a SQLite db of ECHO collection metadata

_echocollectiontool.rb_

Takes a SQLite db of ECHO collection metadata and provides some tools for exploring it.

* * *

### Usage ###

    NAME:

      echocollectiontool.rb

    DESCRIPTION:

      ECHO Collection Explorer

    COMMANDS:

      get
      help                 Display global or [command] help documentation
      summarize

    GLOBAL OPTIONS:

      -V, --verbose
          Enable verbose mode

      -h, --help
          Display help documentation

      -v, --version
          Display version information

      -t, --trace
          Display backtrace when an error occurs
