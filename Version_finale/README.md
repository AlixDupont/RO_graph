
Pour le TP3, certains fichiers sont trop gros pour être transférés. 
Ce sont les fichiers utilisés pour l'affichage en python, utilisés en julia avec 

julia> Values, In, Out = courbe(fichier, [0.1, 0.15, 0.2, 0.5, 0.9], 20)
julia> ythonisation(Values[:,1], Values[:,2], Values[:,3], Values[:,4], Values[:,5], In, Out, 13834639)


pour le second fichier du type, c'est la commande dans le main
julia> courbe_ex3(...)


Pour le TP2, on peut modifier les paramètres dans le fichier main, dans la partie "parametre utilisateur". On peut notamment y choisir l'exercice (1 ou 2) à l'aide des variables ex1 et ex2, ecrire le nom du fichier dont on veut extraire les informations pour l'exercice 1 (mettre le chemin si le fichier texte du graphe n'est pas dans le même répertoire) et créer l'emplacement et le nom des fichier png des plots obtenus (variables nom_fichier_plot_add et nom_fichier_plot_ed).
