moteur = require("stepper")

moteur.init({3,1,2,4})

moteur.rotate(moteur.FORWARD,nil,25)
