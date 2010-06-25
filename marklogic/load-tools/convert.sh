#!/bin/sh

mkdir -p ../marklogic-data

for i in answers comments posts users ;  do
    ruby $i"_parser.rb" "../../data/"$i".xml" ../marklogic-data
done

cd ..
zip -r marklogic-data.zip marklogic-data

