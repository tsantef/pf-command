def prompt(msg, isPassword = false)
  print(msg)
  system "stty -echo" if isPassword
  input = gets
  if isPassword 
    system "stty echo"
    puts ''
  end
  input.strip
end