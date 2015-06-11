providerListTool
====================

A small, dead-simple tool to take a list of providers formatted as follows
          # DOD/USNAVY/NRL/OCEANOGRAPHY ||| 13
          # CA/NRCAN/ESS/GC/CCMEO ||| 13
          # INFOTERRA ||| 13
          # UNEP/GRID-WARSAW ||| 12
          # DOC/NOAA/NMFS/NEFSC ||| 12
          # ESA/ESRIN ||| 12
          # USGCRP ||| 12
          # RUTGERS/CC/DES/GSMDB ||| 12
          # NASA/GSFC/SED/ESD/GMAO ||| 12
          # COLOSTATE/CIRA/CPC ||| 12
          # NASA/GSFC/SED/ESD/HBSL/BISB/MODAPS_SERVICES ||| 12
          # DOI/USGS/SESC ||| 12
          # DOC/NOAA/NESDIS/NODC/OCL ||| 12
          # PRBO/CADC ||| 12

and expand it out into something like this, alphabetized and heirarchially printed, with summed counts
          # CA (13)
          #    |
          #    +-- NRCAN (13)
          #       |
          #       +-- ESS (13)
          #          |
          #          +-- GC (13)
          #             |
          #             +-- CCMEO - 13  (13)
          # COLOSTATE (12)
          #    |
          #    +-- CIRA (12)
          #       |
          #       +-- CPC - 12  (12)
          # DOC (24)
          #    |
          #    +-- NOAA (24)
          #       |
          #       +-- NESDIS (12)
          #          |
          #          +-- NODC (12)
          #             |
          #             +-- OCL - 12  (12)
          #       |
          #       +-- NMFS (12)
          #          |
          #          +-- NEFSC - 12  (12)
          # DOD (13)
          #    |
          #    +-- USNAVY (13)
          #       |
          #       +-- NRL (13)
          #          |
          #          +-- OCEANOGRAPHY - 13  (13)
          # DOI (12)
          #    |
          #    +-- USGS (12)
          #       |
          #       +-- SESC - 12  (12)
          # ESA (12)
          #    |
          #    +-- ESRIN - 12  (12)
          # INFOTERRA - 13  (13)
          # NASA (24)
          #    |
          #    +-- GSFC (24)
          #       |
          #       +-- SED (24)
          #          |
          #          +-- ESD (24)
          #             |
          #             +-- GMAO - 12  (12)
          #             |
          #             +-- HBSL (12)
          #                |
          #                +-- BISB (12)
          #                   |
          #                   +-- MODAPS_SERVICES - 12  (12)
          # PRBO (12)
          #    |
          #    +-- CADC - 12  (12)
          # RUTGERS (12)
          #    |
          #    +-- CC (12)
          #       |
          #       +-- DES (12)
          #          |
          #          +-- GSMDB - 12  (12)
          # UNEP (12)
          #    |
          #    +-- GRID-WARSAW - 12  (12)
          # USGCRP - 12  (12)