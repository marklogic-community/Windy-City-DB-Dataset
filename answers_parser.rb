require 'rexml/document'

Dir.mkdir("#{ARGV[1]}/answers") unless File.directory?(ARGV[1] + "/answers")

File.open(ARGV[0]) do |answers_file|
  # read until we find the first row
  line = answers_file.readline
  until line =~ /row/
    line = answers_file.readline
  end

  count = 1
  begin
    while line && line =~ /row/
      answer = REXML::Document.new(line)
      tags = answer.root.attributes["Tags"].gsub(/["\[\]]/, "").split(",")
      answer_xml = <<BEGIN
  <answer xmlns="http://marklogic.com/windycity">
    <id>#{answer.root.attributes["Id"].strip}</id>
    <creation_date>#{answer.root.attributes["CreationDate"]}</creation_date>
    <owner_id>#{answer.root.attributes["OwnerUserId"]}</owner_id>
<parent_id>#{answer.root.attributes["ParentId"]}</parent_id>
    <body>#{answer.root.attributes["Body"].gsub(/[\r\n]/,"")}</body>
BEGIN
      answer_xml << "<tags>" unless tags.empty?
      tags.each do |tag|
        answer_xml << "<tag>#{tag.strip}</tag>"
      end
      answer_xml << "</tags>" unless tags.empty?
      answer_xml << "</answer>"
      File.open("#{ARGV[1]}/answers/answer#{count}.xml", 'w') do |file|
        file.write answer_xml
      end
      count = count +1
      line = answers_file.readline
    end
  rescue EOFError
    # done
  end


end