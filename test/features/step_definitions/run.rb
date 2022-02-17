require 'open3'

When('running clox with {string}') do |commandline|
    clox = ENV['CLOX_EXECUTABLE']
    @stdout, @stderr, @status = Open3.capture3("#{clox} #{commandline}")
end

When('evaluating {string}') do |expression|
    clox = ENV['CLOX_EXECUTABLE']
    raise "Use single quotes" if expression.include?('"')
    @stdout, @stderr, @status = Open3.capture3("#{clox} --eval \"#{expression}\"")
end

When('compiling {string}') do |expression|
    clox = ENV['CLOX_EXECUTABLE']
    raise "Use only single quotes" if expression.include?('"')
    @stdout, @stderr, @status = Open3.capture3("#{clox} --bytecode --eval \"#{expression}\"")
end

