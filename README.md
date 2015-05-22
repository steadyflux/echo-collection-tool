echo-collection-tool
====================
This repo holds some tools I use to slice and dice ECHO collections/ GCMD DIFs looking for data I am interested in


_retrieveEchoData.rb_

Builds a SQLite db of ECHO collection or granule metadata

_retrieveGcmdData.rb_

Builds a SQLite db of GCMD DIF records

_echoNRTinfo.rb_

Builds a pipe-delimited report of ECHO NRT (near real time) holdings with information about the newest granules

_ingesttool.rb_

Ingests DIF records into ECHO (soon to be CMR) assuming a SQLite db of DIF records exists, also clears data.

_ect.config.yml.template_

Contains config parameters used by tools, needs to be modified with working values and copied into 'ect.config.yml' to utilize these tools

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
    help        Display global or [command] help documentation
    pull_fields
    summarize

  GLOBAL OPTIONS:

    -V, --verbose
        Enable verbose mode

    -G, --granules
        Granules mode

    -D, --dif
        DIF mode

    -h, --help
        Display help documentation

    -v, --version
        Display version information

    -t, --trace
        Display backtrace when an error occurs
