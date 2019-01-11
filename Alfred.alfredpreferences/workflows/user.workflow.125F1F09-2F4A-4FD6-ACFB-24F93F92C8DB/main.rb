# require 'alfred-3_workflow'

# workflow = Alfred3::Workflow.new
require 'json'
searchname = ARGV[0]

podSearchResult = `/usr/local/bin/pod search #{searchname} --simple`

array = podSearchResult.split "\n\n"

resultArr = []
array.each do |model|
  reg_name = /->\s+(.*?)\s+\((.*?)\)\n(.*?)\n.*?-\s+Homepage:\s+(http.*?)\n/im
  group = reg_name.match model
  if group
      items = {}
      items[:arg] = "#{group[4]}|#{group[1]}|#{group[2]}"
      items[:autocomplete] = ""
      items[:icon] = {:path => "both.png"}
      items[:quicklookurl] = group[4]
      items[:uid] = group[4]
      items[:subtitle] = group[3].strip
      items[:title] = "#{group[1]} #{group[2]}"
      items[:type] = "default"
      items[:valid] = true
      resultArr << items
  end
end

resultStr = {:items => resultArr}.to_json
print resultStr
