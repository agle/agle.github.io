

function include_file(p)
  pth = site.templates .. "/" .. p
  f = io.open(pth, "r")
  print(f:read("*a"))
  f:close()
  return;
end


function dump_table(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

