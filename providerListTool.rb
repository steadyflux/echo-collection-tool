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