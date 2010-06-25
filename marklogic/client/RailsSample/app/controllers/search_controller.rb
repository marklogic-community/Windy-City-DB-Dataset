class SearchController < ApplicationController

  def initialize
    @search_options = ActiveDocument::MarkLogicSearchOptions.new
    last60 = ActiveDocument::MarkLogicSearchOptions::ComputedBucket.new("Last 60 Days", "-P60D", "P1D", "now", "Last 60 Days")
    last90 = ActiveDocument::MarkLogicSearchOptions::ComputedBucket.new("Last 90 Days", "-P90D", "P1D", "now", "Last 90 Days")
    lastyear  = ActiveDocument::MarkLogicSearchOptions::ComputedBucket.new("Last Year", "-P1Y", "P1D", "now", "Last Year")
    buckets = [last60, last90, lastyear]
    @search_options.range_constraints["Creation Date"] = {"namespace" => "http://marklogic.com/windycity", "element" => "creation_date", "type" => "xs:dateTime", "computed_buckets" => buckets}
    @search_options.range_constraints["Tag"] = {"namespace" => "http://marklogic.com/windycity", "element" => "tag", "type" => "xs:string", "collation" => "http://marklogic.com/collation/"}
  end

  def index
    start = params[:start]
    if start.nil?
      start = 1
    end
    @query = params[:query]
    if @query.nil? : @query = "" end
    @results = ActiveDocument::Finder.search(@query, start, 10, @search_options)
    @facets = @results.facets
  end

  def show_post
    @post = Post.load(params[:uri])
    @post_owner = User.find_by_identifier(@post.owner_id.text)[0].realize(User)
    @answers = Answer.find_by_parent_id(@post.identifier.text, "answer").collect do |a|
      a.realize(Answer)
    end
    @comments = Comment.find_by_post_id(@post.identifier.text, "comment").collect do |c|
      c.realize(Comment)
    end

    @query = params[:query]
  end

  def show_raw
    headers["Content-Type"] = "application/xhtml+xml; charset=utf-8"
    @incident = Incident.load(params[:uri])
    @query = params[:query]
    render :layout => false
  end

  def edit
    @incident = Incident.load(params[:uri])
  end

  def update
    @incident = Incident.load(params[:incident][:uri])
    @incident.Subject = params[:incident][:Subject]
    @incident.save
    redirect_to :action => "index"
  end

end
