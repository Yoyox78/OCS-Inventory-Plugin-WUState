Wustate

C'est un plugin permettant de remonter les kb qui non pas encore était installé avec un message OK ou NOK pour simplifier la recherche dans le multicritère et indique si le poste à besoin de restart ou non

1er colonne : date

2eme colonne : 
OK: si aucune KB n'est trouvé
NOK: si des KB sont trouvé

3eme colone :
reboot
true : en attente de reboot
false : n'est pas en attente de reboot

4eme colonne : 
les KB concernées en attente d'installation ou de download et installation


Je supprime les doublons pour eviter d'avoir la même KB affichées plusieurs fois
Je me base sur le plugin WindowsUpdate de powershell galaxy
