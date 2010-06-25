require 'rexml/document'

Dir.mkdir("#{ARGV[1]}/comments") unless File.directory?(ARGV[1] + "/comments")

File.open(ARGV[0]) do |comments_file|
  # read until we find the first row
  line = comments_file.readline
  until line =~ /row/
    line = comments_file.readline
  end

  count = 1
  begin
    while line && line =~ /row/
      comment = REXML::Document.new(line)
      comment_xml = <<BEGIN
    <comment xmlns="http://marklogic.com/windycity">
    <identifier>#{comment.root.attributes["Id"].strip}</identifier>
    <creation_date>#{comment.root.attributes["CreationDate"]}</creation_date>
    <user_id>#{comment.root.attributes["UserId"]}</user_id>
    <post_id>#{comment.root.attributes["PostId"]}</post_id>
    <body>#{comment.root.attributes["Body"].gsub(/[\r\n]/,"")}</body>
BEGIN
      comment_xml << "</comment>"
      File.open("#{ARGV[1]}/comments/comment#{count}.xml", 'w') do |file|
        file.write comment_xml
      end
      count = count +1
      line = comments_file.readline
    end
  rescue EOFError
    # done
  end


end