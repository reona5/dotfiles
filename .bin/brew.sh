#!/bin/bash

# install packages in Brewfile
brew bundle install --global --verbose

# NOTE: https://github.com/Homebrew/homebrew-bundle/issues/1062
brew link --overwrite git
