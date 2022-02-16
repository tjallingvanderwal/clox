require 'open3'
require 'active_support/all'

Then('the result is {string}') do |expected|
    expect(@status.exitstatus).to eql(0)
    expect(@stdout.lines.last.chomp).to eql(expected)
end

Then('the result contains {string}') do |expected|
    expect(@status.exitstatus).to eql(0)
    expect(@stdout.lines.last).to include(expected)
end

Then('the script fails with {string}') do |expected|
    expect(@status.exitstatus).not_to eql(0)
    expect(@stderr).to include(expected)
end

Then('the bytecode looks like:') do |doc_string|
    expect(@stdout.squish).to eql(doc_string.squish)
end
