#!/bin/sh

for i in "answers comments posts" ;  do
    ruby ${i}"_parser.rb" "data/"{$i}".xml" marklogic-data
done

zip -r marklogic-data.zip marklogic-data

