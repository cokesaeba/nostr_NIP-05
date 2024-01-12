-- Importamos el módulo JSON
local cjson = require "cjson"

-- Definimos la ruta del archivo JSON
-- local json_file_path = "/usr/local/openresty/nginx/html/.well-known/nostr.json"
local json_file_path = "./nostr.json"

-- Leemos el archivo JSON
local file = io.open(json_file_path, "r")
if file == nil then
       print("Error opening file")
       return
end
local content = file:read("*all")
file:close()

-- cjson.encode_keep_buffer(false)
-- Convertimos el contenido del archivo a una tabla LUA
local data = cjson.decode(content)

-- Obtenemos el nombre de los argumentos de la línea de comandos
local name = arg[1]:match("name=(.*)")

-- Buscamos el nombre en la tabla
if data.names[name] then
       -- Si el nombre existe, obtenemos la clave pública
       local public_key = data.names[name]
   
       -- Buscamos los relays asociados a la clave pública
       local relays = data.relays[public_key]

       -- si no hay relays solo imprimimos el nombre y la clave pública
       if relays == nil then
              print(cjson.encode({names = {[name] = public_key}}))
              return
       end

       -- codificamos a JSON los datos correspondientes
       -- local str_result = cjson.encode({names = {[name] = public_key}, relays = {[public_key] = relays}})

       -- divido la cadena en dos para forzar un orden correcto en el JSON
       local str_names = cjson.encode({names = {[name] = public_key}})
       local str_relays = cjson.encode({relays = {[public_key] = relays}})

       str_names = str_names:sub(1, -2) -- eliminamos el último carácter de la cadena (la } de names)
       str_relays = str_relays:sub(2) -- eliminamos el primer carácter de la cadena (la { de relays)
       
       -- concatenamos las cadenas en un único json:
       local str_result = str_names .. ',' .. str_relays
       -- limpiamos la cadena para sustituir las barras escapadas wws:\/\/ por wws://
       str_result = string.gsub(str_result, "\\/", "/")
       print(str_result)
else
       -- Si el nombre no existe, imprimimos nulo
       print(cjson.encode({names = {}}))
end