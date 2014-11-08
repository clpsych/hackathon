#!/usr/bin/env ruby
require 'json'
require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'

parse = File.open(ARGV[0], "r")
ids = File.open(ARGV[1], "r")


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
    end
  end
  g = RGL::DirectedAdjacencyGraph[*edges]
  sentences = []
  g.to_undirected.each_connected_component { |c| sentences << c.to_a.sort.map {|i| current_lines[i-1][1] }.join(" ")}
  h = {id: current_id, sentences: sentences}
  puts h.to_json
end

parse.close
ids.close

