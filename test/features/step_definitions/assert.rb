require 'open3'
require 'active_support/all'

# Reformat actual output and expected output
# so that tests are less finicky about whitespace.
#
# 1. Remove redundant whitespace within lines
# 2. Remove empty lines
# 3. Preserve newlines so that RSpec will produce nice diffs
def normalize_ws(string)
    string.lines.map(&:squish)
                .reject(&:blank?)
                .join("\n")
end

def expect_output(actual, expected)
    expect(normalize_ws(actual)).to eql(normalize_ws(expected))
end

Then('the result is {string}') do |expected|
    expect(@status.exitstatus).to eql(0)
    expect(@stdout.chomp).to eql(expected)
end

Then('the result is the string {string}') do |expected|
    expect(@status.exitstatus).to eql(0)
    expect(@stdout.chomp).to eql("\"#{expected}\"")
end

Then('the script fails with {string}') do |expected|
    expect(@status.exitstatus).not_to eql(0)
    expect(@stderr).to include(expected)
end

Then('clox fails with:') do |doc_string|
    expect(@status.exitstatus).not_to eql(0)
    expect_output(@stderr, doc_string)
end

Then('clox prints to stdout:') do |expected|
    expect_output(@stdout, expected)
end

Then('the bytecode looks like:') do |expected|
    expect_output(@stdout, expected)
end
