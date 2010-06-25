require 'rexml/document'

Dir.mkdir("#{ARGV[1]}/users") unless File.directory?(ARGV[1] + "/users")

File.open(ARGV[0]) do |users_file|
  # read until we find the first row
  line = users_file.readline
  until line =~ /row/
    line = users_file.readline
  end

  count = 1
  begin
    while line && line =~ /row/
      user = REXML::Document.new(line)
      user_xml = <<BEGIN
  <user xmlns="http://marklogic.com/windycity">
    <identifier>#{user.root.attributes["Id"].strip}</identifier>
    <display_name>#{user.root.attributes["DisplayName"]}</display_name>
BEGIN
      user_xml << "</user>"
      File.open("#{ARGV[1]}/users/user#{count}.xml", 'w') do |file|
        file.write user_xml
      end
      count = count +1
      line = users_file.readline
    end
  rescue EOFError
    # done
  end


end