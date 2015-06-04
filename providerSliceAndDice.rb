# small tool to take a list of providers formatted as follows
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
# and rolls it up into something like this, alphabetized and heirarchially printed
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

@provider_hash = Hash.new(0)
@provider_names = Hash.new(0)

def build_level token_array, current_index, value_hash, top_level_only=false
  if (token_array[current_index+1])
    # puts "recursing: #{token_array[current_index]}"
    value_hash[token_array[current_index]] = Hash.new(0) unless value_hash[token_array[current_index]].is_a?(Hash)
    build_level(token_array, current_index + 1,  value_hash[token_array[current_index]]) unless top_level_only
  else
    # puts "leafing: #{token_array[current_index]}"
    value_hash[token_array[current_index]] = Hash.new(0) unless value_hash[token_array[current_index]].is_a?(Hash)
  end
end

def sum_children parent
  sum = 0
  @provider_names.keys.each { |k| sum = sum + @provider_names[k].to_i if k.start_with?(parent) }
  sum
end

def print_indent(depth, output)
    if depth > 0
      depth.times{ output << "   " }
      output << "|\n"
      depth.times{ output << "   " }
      # output << "\\-- "
      output << "+-- "
    end
    output
end

def print_tree value_hash, depth, pathname, output
  value_hash.keys.sort.each do |k|
    new_pathname = (pathname == "") ? k : "#{pathname}/#{k}"
    print_indent depth, output
    output << "#{k}"
    output << " - #{@provider_names[new_pathname]} " if @provider_names[new_pathname] != 0
    output << " (#{sum_children(new_pathname)})\n"
    print_tree(value_hash[k], depth+1, new_pathname, output) if value_hash[k] != 1
  end
  output
end

File.readlines("firstdatacenternames.txt").each do |datacenter|
  name, count = datacenter.split(" ||| ")
  tokenized_name = name.split("/")
  @provider_names[name] = count.strip
  build_level(tokenized_name, 0, @provider_hash)
end

output = print_tree(@provider_hash, 0, "", "")
puts output