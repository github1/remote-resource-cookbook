#!/usr/bin/env bash
set -e

echo Preparing dependencies ...
bundle install

echo Running rspec ...
for d in test/spec/**/*; do
  echo Running chefspec on $d...
  bundle exec rspec $d --format documentation
done

echo Running foodcritic ...
bundle exec foodcritic -t ~FC085 -f any ./