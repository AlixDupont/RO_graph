include("TP1.jl")    # nom du fichier du tp1


# -------------- fonction k_core -------------
# Arguments :
# fichier -> nom du fichier comportant le graphe
# informations_core -> variable binaire qui indique si oui ou non on veut recevroi des informations au cours de la simulation

# Renvoie :
# c -> core maximal obtenus
# liste_core -> liste de taille nombre de noeud qui donne a chaque numero de noeud son core
# ordre_noeud -> liste de taille nombre de noeud qui donne a chaque numero de noeud le rang (en partant de la fin) par lequel il a ete traite
# tri_noeud ->  liste de taille nombre de noeud qui donne a chaque rang le numero du noeud qui a ete traite a ce rang (en partant de la fin)

# utilise les fonctions adjacency_a et counting du tp1

function k_core(fichier, informations_core)

    degres, liste_degres, voisins = adjacency_a(fichier)
    # liste_degres : liste de taille nb_noeud qui donne le degres de chaque noeud
    # voisins : liste de liste : a chaque element de la liste on a la liste de tous les voisins correspondants

    n, a, inf = counting(fichier) 
    # n : nombre de noeuds

    # initialisations
    max_degree = Int(maximum(liste_degres))    # degre maximum original du graphe 
    compteur_degree = zeros(max_degree+1)      # pour chaque degre donne le nombre de noeud ayant ce degre
    noeud = 0                                  # numero du noeud en cours de traitement
    ordre_noeud = zeros(n+1-inf)               # a chaque noeud indique son ordre
    tri_noeud = zeros(n+1-inf)                 # a chaque ordre indique son noeud
    liste_core = zeros(n+1-inf)                # liste qui indique le core de chaque noeud
    c = 0                                      # core pour chaque noeud

    # initialisation de compteur_degree
    for i in 1:n+1-inf
        compteur_degree[Int(liste_degres[i])+1] += 1       # decalage : le 1er element correspond au degre 0, 2eme element au degre 1, etc..
    end
    
    # boucle sur le nombre total de noeud. A chaque iteration correspond au traitement d un noeud
    for i in 1:n+1-inf

        
        stop = 0     # variable qui va indiquer plus tard si on sort de la boucle
        
        # choix du noeud : on prend le premier noeud de la liste de noeuds (non vide) ayant le degre le plus faible
        for j in 0:max_degree          
            
            if compteur_degree[j+1] > 0      # si la liste de noeuds ayant le degre j est non vide

                for k in 1:n+1-inf           # on choisit le premier noeud de la liste ayant de degre j 

                    
                    if Int(liste_degres[k]) == j
                        
                        noeud = k                         # on choisit le noeud k
                        ordre_noeud[noeud] = n+2-inf-i    # l ordre du noeud est n+2-inf-i (on prend l ordre inverse)
                        tri_noeud[n+2-inf-i] = noeud      # le noeud de rang n+2-inf-i est donc "noeud"
                        compteur_degree[j+1] -= 1         # on met a jour le compteur car il y a un noeud de moins ayant le degre j
                        stop = 1                          # vu qu on prend le premier noeud qui verifie le critere, on s arete 
                        break
                    end
                end
            end

            # le choix du noeud a ete fait, donc on sort de la boucle
            if stop == 1
                break         
            end
            
        end
        
        c = max(c, Int(liste_degres[noeud]))    # core du noeud actuel 
        liste_core[noeud] = c                   # on met a jour a liste des core pour le noeud actuel
        liste_degres[noeud] = -1                # on met le degre du noeud a -1 pour ne plus le considerer dans le graphe

        # mise a jour du degree et des compteurs du faite qu on enleve le noeud actuel du graphe
        # pour chaque voisin du noeud actuel, on retire de 1 son degre
        for n in voisins[noeud]

            # cas de figure impossible, si c est un voisin du noeud actuel, alors il doit forcement avoir un degre non nul
            if Int(liste_degres[n]) == 0
                println("erreur : le degré d'un voisin du noeud sélectionné ne peut pas être nul")
                stop = 2
            

            elseif Int(liste_degres[n]) > 0

                # attention au decalage des indices
                compteur_degree[Int(liste_degres[n])+1] -= 1    # il y a un noeud de degre "liste_degres[n]" en moins
                liste_degres[n] -= 1                            # le degre de n diminue de 1
                compteur_degree[Int(liste_degres[n])+1] += 1    # il y a un noeud de degre "liste_degres[n]-1" en plus

            end

        end
        
        # si on veut obtenir des informations au cours de la simulation
        if informations_core == 1

            # on receuille des informations toutes les 10 000 iterations
            if mod(i,10000) == 0
                println("iter_core = ", i)
                println("pourcentage_simulation_core = ", 100*i/n,"%")
                println("compteur_degree_0_9 = ", compteur_degree[1:10])
                println("core maximal en cours = ", c)
                println("degre maximal en cours = ", maximum(liste_degres) )
                println(" ")
            end
        end

        # il y a une erreur dans la simulation, donc on sort de la boucle
        if stop == 2
            break
        end
    end

    # si on veut obtenir des informations au cours de la simulation
    if informations_core == 1
        println("iter_core = ", n)
        println("pourcentage_simulation_core = ", 100,"%")
        println("core maximal en cours = ", c)
        println("degre maximal en cours = ", maximum(liste_degres) )
    end

    return c, liste_core, ordre_noeud, tri_noeud

end




# ------------- fonction density_prefix ---------------

# Arguments
# fichier -> nom du fichier comportant le graphe
# ordre_noeud -> meme variable que pour la fonction k_core
# tri_noeud -> meme variable que pour la fonction k_core
# informations_density -> variable binaire qui indique si oui ou non on veut recevroi des informations au cours de la simulation

# Renvoie
# max_add -> average degree density maximale des sous-graphe prefix
# size_max_add -> taille du sous-graphe ayant l average degree density maximale
# liste_add -> liste de taille nombre de noeud qui a chaque entier i donne l average degree density du sous-graphe prefix de taille i
# max_ed -> edge density maximal des sous-graphes prefix
# size_max_ed -> taille du sous-graphe ayant l edge density maximale
# liste_ed -> liste de taille nombre de noeud qui a chaque entier i donne l edge density du sous-graphe prefix de taille i

# utilise la fonction adjacency_a du tp1

function density_prefix(fichier, ordre_noeud, tri_noeud, informations_density)


    degres, liste_degres, voisins = adjacency_a(fichier)
    # voisins : liste de liste : a chaque element de la liste on a la liste de tous les voisins correspondants
 
    # Verification que les tailles des listes ordre_noeud et tri_noeud sont identiques
    if length(ordre_noeud) != length(ordre_noeud)
        println("erreur : taille des listes ordre_noeud et tri_noeud différente")
    end

    # taille du graphe (nombre de noeuds)
    n = length(ordre_noeud)
    
    liste_add = zeros(n)  # add = average degree density
    liste_ed = zeros(n)   # ed = edge density
    nb_noeud = 0          # nombre de noeud des sous-graphes
    nb_arete = 0          # nombre d' arete des sous-graphes
    max_add = 0           # average degree density maximal des sous-graphes prefix
    size_max_add = 0      # taille du sous-graphe ayant l average degree density maximale
    max_ed = 0            # edge density maximal des sous-graphes prefix
    size_max_ed = 0       # taille du sous-graphe ayant l edge density maximale

    for i in 1:n

        # ajout d un nouveau noeud
        noeud = Int(tri_noeud[i])
        
        # augmentation du nombre de noeud par 1
        nb_noeud +=1

        # augmentation du nombre d arete
        # faire intersection avec les noeud du graphe et les voisins
        for v in voisins[noeud]

            if ordre_noeud[v] <= i-1    # si l'ordre du noeud n est inferieur a i-1, alors le voisin n appartient au sous-graphe
                nb_arete += 1
            end

        end
        
        # average degree density du sous-graphe actuel
        liste_add[i] = nb_arete / nb_noeud

        # edge density du sous-graphe actuel (distinction de cas car on ne peut pas diviser par 0)
        if i == 1
            liste_ed[i] == 0
        else
            liste_ed[i] = 2*nb_arete/(nb_noeud*(nb_noeud-1))   # ed : edge_density
        end

        # si l average degree density en plus grand que tous les precedents, alors on met a jour max_add et size_max_add
        if liste_add[i] >= max_add
            max_add = liste_add[i]
            size_max_add = i
        end

        # idem pour l edge density
        if liste_ed[i] >= max_ed
            max_ed = liste_ed[i]
            size_max_ed = i
        end
        
        # 
        if informations_density == 1
            if mod(i,10000) == 0
                println("iter_density = ", i)
                println("pourcentage_simulation_density = ", 100*i/n,"%")
                println("densite de degre maximale en cours = ", max_add)
                println("densite d arete maximale en cours = ", max_ed)
                println(" ")
            end
        end

    end

    # si on veut obtenir des informations au cours de la simulation
    if informations_density == 1
        println("iter_density = ", n)
        println("pourcentage_simulation_density = ", 100,"%")
        println("densite de degre maximale en cours = ", max_add)
        println("densite d arete maximale en cours = ", max_ed)
    end


    return max_add, size_max_add, liste_add, max_ed, size_max_ed, liste_ed
    
end

# ------------- fonction anomalous_authors ---------------

# Arguments :
# liste_degres -> liste de taille nombre de noeud qui a chaque numero de noeud donne son degre
# liste_core -> liste de taille nombre de noeud qui a chaque numero de noeud donne son core
# ratio -> ratio core/degre a partir duquel il on considere un noeud comme etant anormal

# Renvoie :
# -> liste_anomalous : liste des noeuds anormaux

function anomalous_authors(liste_degres, liste_core, ratio)

    if length(liste_degres) != length(liste_core)
        println("erreur : taille de la liste des degrés différente de celle de la liste des core")
    end
    
    n = length(liste_degres)

    liste_anomalous = []
   

    for i in 1:n

        if liste_degres[i]/liste_core[i] > ratio
            append!(liste_anomalous,[i-1])
        end
    
    end

    return liste_anomalous

end


# ------------- fonction name_authors ---------------

# Arguments
# fichier : fichier compartant les noms correspondant aux noeuds
# liste_anomalous : liste des noeuds anormaux

# Renvoie
# liste_ID : liste des noms correspondant aux noeuds anormaux

# utilise la fonction conversion du tp2

function name_authors(fichier, liste_anomalous)

    f = open(fichier)

    # n = nombre de ID
    n = 0
    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        else
            n += 1
        end
    end
    println("max = ", maximum(liste_anomalous))
    println("n = ", n)
    liste_detection = zeros(n)
    for i in 1:length(liste_anomalous)
        liste_detection[ liste_anomalous[i]+1 ] = 1
    end

    liste_ID = []
    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        number, ID = conversion_ID(ln)

        
        if liste_detection[number+1] == 1
            append!(liste_ID,[ID])
        end
        

       
    end
    
    close(f)

    return liste_ID

end

# ------------- fonction name_authors ---------------

# Arguments
# chaine : chaine de caractere avec le numero d un noeud puis son nom correspondant separe d un espace

# Renvoie
# parse(Int,C_int) : entier correspondant au numero du noeud
# C_name : chaine de caractere correspondant au nom associe au noeud

function conversion_ID(chaine)   # chaine : chaine de caracteres
    #println(chaine)
    n = length(chaine)     # longueur de la chaine

    C_int = []    # numero du noeud 1
    C_name = []    # numero du noeud 2

    for i in 1:n

        if chaine[i] == '1' || chaine[i] == '2' || chaine[i] == '3' || chaine[i] == '4' || chaine[i] == '5' || chaine[i] == '6' || chaine[i] == '7' || chaine[i] == '8' || chaine[i] == '9' || chaine[i] == '0'
            continue
        else
            C_int = chaine[1:i-1]
        

            C_name = chaine[i+1:lastindex(chaine)]
            #append!(C_name,chaine[n])


            break
        end
    end

    return parse(Int,C_int), C_name
end



# ---------------- fonctions k_core_bis et select_core qui se sont finalement avere inutiles ---------------

#=
function k_core_bis(fichier)
    
    println("in_k_core1")

    f = open(fichier)


    degres, liste_degres, voisins = adjacency_a(fichier)
    # liste_degres : liste de taille nb_noeud qui donne le degres de chaque noeud
    # degres : inutile ici
    # voisins : liste de liste : a chaque element de la liste on a la liste de tous les voisins correspondants

    c = 0    # maximum k_core
    n, a, inf = counting(fichier)  # n : nombre de noeuds

    println("in_k_core2")

    M = maximum(liste_degres)+1   # on changera les valeurs des noeuds degre_brouillon en M une fois qu'ils seront parcourus 
    
    degre_brouillon = copy(liste_degres)
    liste_core = -1 * ones(n+1-inf)     # core du noeud



    for i in 1:n+1-inf
        noeud = argmin(degre_brouillon)  # trop long et faut !

        nb_voisin = length(voisins[noeud])   # ou : nb_voisin = degre_brouillon[noeud]
        s = 0   # nombre de voisins non utilises
        for j in 1:nb_voisin
            if liste_core[voisins[noeud][j]] == -1.0   # cas ou voisins[j] n a pas encore ete parcouru
                s += 1
                

            end
        end
        c = max(c,s)
        liste_core[noeud] = c

        degre_brouillon[noeud] = M


        # pour voir l avancement du programme
        if mod(i,10000) == 0
            println(i/10000)
        end
    end
    println("in_k_core3")
    
    c_max = maximum(liste_core)
    close(f)
    return c_max, liste_core
end
=#


#=


function select_core(fichier,p)

    println("in_select_core1")

    f = open(fichier)
    c_max, liste_core = k_core(fichier)

    println("in_select_core2")

    degres, liste_degres, voisins = adjacency_a(fichier)
    println("in_select_core3")
    n = length(liste_core)

    liste_select = []   # liste de tous les noeuds ayant un core p
    nb_noeud = 0
    nb_arete = 0
    
    

    
    nb_noeud_p = 0
    for i in 1:n
        if liste_core[i] == p 
            nb_noeud_p +=1
        end
    end
    list_density = zeros(nb_noeud_p)
    println("nb_noeud_p = ", nb_noeud_p)

    println("in_select_core3")

    # on recupere tous les noeuds ayant un core egal a p
    for i in 1:n    # i = numero du noeud ; on parcours tous les noeuds
        #println("liste_core[i] = ", liste_core[i])
        #println("p = ", p)
        # on ajoute liste_core[i] a liste_select si le core du noeud i vaut p
        if liste_core[i] == p 
           
            println("before")
            v = length(voisins[Int(liste_core[i])])   # nombre de voisins du noeud i
            #println("v = ", v)

            # on parcours tous les voisins du noeud i
            for j in 1:v   # voisins[liste_core[i]][j] = numero du j^eme voisin de i

                for k in 1:nb_noeud     # on parcours les noeuds du sous-graph
                    if voisins[Int(liste_core[i])][j] == liste_select[k]
                        nb_arete += 1    # on est tombe sur une arete, donc le nombre d aretes augmente de 1
                        break
                    end
                end

            end

            append!(liste_select,[i])   # on ajoute le noeud i a la liste
            nb_noeud += 1
            list_density[nb_noeud] = nb_arete/nb_noeud
            println(nb_noeud)

        end



    end

    if nb_noeud == 0
        println("il n'y a aucun noeud ayant un core de ", p)
        return [0]    # On note par convention que le densite de l'ensemble vide est 0. 
    end

    
    # nb_noeud = length(liste_select)
    println("nb_arete = ", nb_arete)
    println("nb_noeud = ", nb_noeud)
    # on connait le nombre d aretes et de noeuds du sous-graph, on peut donc calculer la densite moyenne
    # a = nb_arete/nb_noeud

    close(f)

    return list_density      # retourne la liste de densite des sous-graphes apres chaque ajout de noeud

end


=#

