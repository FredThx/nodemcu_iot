for n in pairs(file.list("^.*%.l[uac]+$")) do
f = file.open(n..".chk", "r")
if f then c = string.gsub(f:read('\n') or "",'\n','') f:close() end
App.mqtt_publish('{"file" : "'..n..'", "chk" : "'..(c or "")..'"}', App.mqtt.base_topic .. '_FILE')
end
