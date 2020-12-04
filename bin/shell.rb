begin
binding.pry
rescue => err
  log("ShellError", err.message)
  puts err.full_message
end
