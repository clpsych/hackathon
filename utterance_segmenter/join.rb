#!/usr/bin/env ruby
require 'json'
require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'

parse = File.open(ARGV[0], "r")
ids = File.open(File.join(File.dirname(ARGV[0]), File.basename(ARGV[0], ".tweets.txt.predict") + ".ids.txt"), "r")

while ids.gets
  current_id = $_.chomp
  current_lines = []
  edges = []
  while parse.gets
    line = $_.chomp
    break if line.length == 0
    line = line.split(/\t/)
    current_lines << line

    head = line[6].to_i
    if head > 0
      edges << line[0].to_i << head
    elsif head == 0 
      #make sure you include a link from a root to itself, 
      #so it appears in the graph if utterance is only one token
      edges << line[0].to_i << line[0].to_i
    end
  end
  
  #build graph from dependencies
  g = RGL::DirectedAdjacencyGraph[*edges]
  tree = current_lines.map { |l| [l[1], l[3], l[6]].join("/") }.join(' ')
  utterances = []

  #pull out connected components
  g.to_undirected.each_connected_component { |c| utterances << c.to_a.sort }
  #sort by order of first token
  utterances = utterances.sort_by { |u| u[0] }
  #pull out token information for each utterance
  utterances = utterances..map {|u| u.map { |i| l = current_lines[i-1]; [l[1], l[3]].join("/") }.join(" ")}
  h = {id: current_id, utterances: utterances, tree: tree}
  puts h.to_json 
end

parse.close
ids.close

