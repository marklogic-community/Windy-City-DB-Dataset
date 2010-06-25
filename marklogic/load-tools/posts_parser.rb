require 'rexml/document'

Dir.mkdir("#{ARGV[1]}/posts") unless File.directory?(ARGV[1] + "/posts")

File.open(ARGV[0]) do |posts_file|
  # read until we find the first row
  line = posts_file.readline
  until line =~ /row/
    line = posts_file.readline
  end

  count = 1
  begin
    while line && line =~ /row/
      post = REXML::Document.new(line)
      tags = post.root.attributes["Tags"].gsub(/["\[\]]/, "").split(",")
      post_xml = <<BEGIN
  <post xmlns="http://marklogic.com/windycity">
    <identifier>#{post.root.attributes["Id"].strip}</identifier>
    <creation_date>#{post.root.attributes["CreationDate"]}</creation_date>
    <owner_id>#{post.root.attributes["OwnerUserId"]}</owner_id>
    <body>#{post.root.attributes["Body"].gsub(/[\r\n]/,"")}</body>
BEGIN
      post_xml << "<tags>" unless tags.empty?
      tags.each do |tag|
        post_xml << "<tag>#{tag.strip}</tag>"
      end
      post_xml << "</tags>" unless tags.empty?
      post_xml << "</post>"
      File.open("#{ARGV[1]}/posts/post#{count}.xml", 'w') do |file|
        file.write post_xml
      end
      count = count +1
      line = posts_file.readline
    end
  rescue EOFError
    # done
  end


end