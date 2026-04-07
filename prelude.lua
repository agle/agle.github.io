

function include_file(p)
  pth = site.templates .. "/" .. p
  f = io.open(pth, "r")
  print(f:read("*a"))
  f:close()
  return;
end
