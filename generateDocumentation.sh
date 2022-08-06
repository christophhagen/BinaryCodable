# Switch to the ruby environment where jazzy is installed
chruby ruby-3.1.0
# Run the generation using the .jazzy.yaml configuration file
jazzy
# Copy the documentation badge so that it can be found using the relative link in the readme
mkdir -p docs/docs
cp docs/badge.svg docs/docs/badge.svg
# Copy the remaining badges
mkdir -p docs/assets
cp assets/*.svg docs/assets/

echo 'Generation complete'
