# This script attempts to automate the generation of the HTML documentation
# for this swift package. It relies on [jazzy](https://github.com/realm/jazzy).
#
# To use this script:
# Install chruby
#     sudo gem install chruby
# Install ruby-build
#     brew install ruby-build
# Install ruby version and switch
#     ruby-build 3.3.0 ~/.rubies/ruby-3.3.0
#     chruby ruby-3.3.0
# Install jazzy
#     gem install jazzy

# Switch to the ruby environment where jazzy is installed
chruby ruby-3.3.0

# Run the generation using the .jazzy.yaml configuration file
jazzy

# Copy the documentation badge so that it can be found using the relative link in the readme
# Note: The readme needs the assets to be in /assets, while the HTML docs need the assets in /docs/assets
mkdir -p docs/docs
cp docs/badge.svg docs/docs/badge.svg

# Copy the remaining badges and logo
mkdir -p docs/assets
cp assets/* docs/assets/

echo 'Generation complete'
