require 'open3'
require 'active_support/all'

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
    expect(@stderr.chomp).to eql(doc_string)
end

Then('clox prints to stdout:') do |doc_string|
    expect(@stdout.squish).to eql(doc_string.squish)
end

Then('the bytecode looks like:') do |expected_bytecode|
    expect(@stdout.squish).to eql(expected_bytecode.squish)
end
