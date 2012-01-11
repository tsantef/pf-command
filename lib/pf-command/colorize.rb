def colorize(str, beginColor, endColor = 0)
  "\e[#{beginColor}m#{str}\e[#{endColor}m"
end

#30	Black
def black(str, endColor = 0)
  colorize(str, "30", endColor)
end

#31	Red
def red(str, endColor = 0)
  colorize(str, "31", endColor)
end

#31	Red
def bred(str, endColor = 0)
  colorize(str, "1;31", endColor)
end

#32	Green
def green(str, endColor = 0)
  colorize(str, "32", endColor)
end

#32	Bright Green
def bgreen(str, endColor = 0)
  colorize(str, "1;32", endColor)
end

#33	Yellow
def yellow(str, endColor = 0)
  colorize(str, "33", endColor)
end

#33	Yellow
def byellow(str, endColor = 0)
  colorize(str, "1;33", endColor)
end

#34	Blue
def blue(str, endColor = 0)
  colorize(str, "34", endColor)
end

#34	Blue
def bblue(str, endColor = 0)
  colorize(str, "1;34", endColor)
end

#35	Magenta
def magenta(str, endColor = 0)
  colorize(str, "35", endColor)
end

#35	Magenta
def bmagenta(str, endColor = 0)
  colorize(str, "1;35", endColor)
end

#36	Cyan
def cyan(str, endColor = 0)
  colorize(str, "36", endColor)
end

#36	Bright Cyan
def bcyan(str, endColor = 0)
  colorize(str, "1;36", endColor)
end

#37	White
def white(str, endColor = 0)
  colorize(str, "37", endColor)
end

#37	Bright White
def bwhite(str, endColor = 0)
  colorize(str, "1;37", endColor)
end
