require 'open3'

When('running clox with {string}') do |commandline|
    clox = ENV['CLOX_EXECUTABLE']
    @stdout, @stderr, @status = Open3.capture3("#{clox} #{commandline}")
end

def run_file(commandline, lox_code)
    file = Tempfile.open(['test', '.lox'])
    file.write(lox_code)
    file.close

    clox = ENV['CLOX_EXECUTABLE']
    @stdout, @stderr, @status = Open3.capture3("#{clox} --file #{file.path} #{commandline}")
    file.unlink
end

When('running a clox file:') do |lox_code|
    run_file('', lox_code)
end

When('running a clox file with options {string}:') do |commandline, lox_code|
    run_file(commandline, lox_code)
end

When('evaluating {string}') do |expression|
    clox = ENV['CLOX_EXECUTABLE']
    raise "Use single quotes" if expression.include?('"')
    @stdout, @stderr, @status = Open3.capture3("#{clox} --eval \"print #{expression};\"")
end

When('evaluating {string} with tracing') do |expression|
    clox = ENV['CLOX_EXECUTABLE']
    raise "Use single quotes" if expression.include?('"')
    @stdout, @stderr, @status = Open3.capture3("#{clox} --eval \"print #{expression};\" --trace")
end

When('compiling {string}') do |expression|
    clox = ENV['CLOX_EXECUTABLE']
    raise "Use only single quotes" if expression.include?('"')
    command = "#{clox} --bytecode --eval \"#{expression};\""
    @stdout, @stderr, @status = Open3.capture3(command)
end

When('compiling:') do |lox_code|
    run_file("--bytecode", lox_code)
end
