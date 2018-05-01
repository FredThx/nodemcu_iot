-----------------------------------------------------------------------
--
-- Projet : Serveur Web 100% local
----------------------------------------------------------------------
-- description des pages html à charger
--
--  Usage :
--              server.http_pages[path] = function(method, path)
--                          do_actions()
--                          return server.read_file("fichier.html")
--                  ou server = dofile("server.lua")
--
--   Si la page n'est pas reference, elle est charge si existe en memoire flash
--  Interet de la reference : ajouter des traitements
----------------------------------------------------------------------
-- Auteur : FredThx
----------------------------------------------------------------------

server.http_pages['/resultats.html'] = {
	http = function (method, path)
				if _GET["action"]=='raz' then
					pcchrono.results={}
				end
				return server.read_file("resultat.html")
			end
}


server.http_pages['/'] = {
	http = function (method, path)
				if _GET["action"]=='ON' then
					gpio.write(pcchrono.aimant.pin,gpio.HIGH)
				end
				if _GET["action"]=='OFF' then
					gpio.write(pcchrono.aimant.pin,gpio.LOW)
				end
				return server.read_file("index.html")
			end,
	cache = true
}

server.http_pages['/acquisition.html'] = {
	http = function (method, path)
				print(method, path)
				if _GET["action"]=='aimant_change' then
					if (gpio.read(pcchrono.aimant.pin)==gpio.HIGH) then
						gpio.write(pcchrono.aimant.pin,gpio.LOW)
					else
						gpio.write(pcchrono.aimant.pin,gpio.HIGH)
					end
				elseif _GET["action"]=='go' then
					if not pcchrono.run then
						dofile("lecture_capteurs.lc")
						return server.read_file("resultats.html")
					end
				elseif _GET["action"]=='raz' then
					pcchrono.results={}
				end
				return server.read_file("acquisition.html")
			end
}

server.http_pages['/donnees_experience.html'] = {
	http = function (method, path)
				if _GET["diametre_bille"] then
					pcchrono.aimant.diam = tonumber(_GET["diametre_bille"])
					for k, fourche in pairs(pcchrono.fourches) do
						fourche.d=tonumber(_GET["cellule_"..k]) or 0
					end
					local f_pcchrono = file.open("pcchrono.cfg","w")
					f_pcchrono.writeline(sjson.encode(pcchrono))
					f_pcchrono.close()
				end
				return server.read_file("donnees_experience.html")
			end
}
server.http_pages['/style.css'] = {
	cache = true
}
server.http_pages['/pierron.gif'] = {
	cache = true
}