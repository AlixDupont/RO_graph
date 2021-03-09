include("tp1_b.jl")

function k_core(fichier)
    # mauvais calcul


    # j'ai besoin de :
    # liste de tous les noeuds
    # degrés de chaque noeud

    #=
    peuso code 
    ln = liste de noeud dans l'ordre du numéro
    ln_trié = liste de noeud trié par degré
    mark = 1 si le noeud a déjà été parcouru
    core = k-core de chaque noeud
    =#

    

    f = open(fichier)

   

    degres, liste_degres, voisins = adjacency_a(fichier)
    # liste_degres : liste de taille nb_noeud qui donne le degres de chaque noeud
    # degres : inutile ici
    # voisins : liste de liste : a chaque element de la liste on a la liste de tous les voisins correspondants

    c = 0    # maximum k_core
    n, a, inf = counting(fichier)  # n : nombre de noeuds

   

    M = maximum(liste_degres)+1
    
    degre_brouillon = copy(liste_degres)
    liste_core = -1 * ones(n)     # core du noeud
    for i in 1:n+1-inf
        noeud = argmin(degre_brouillon)

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
    
    
    c_max = maximum(liste_core)
    close(f)
    return c_max, liste_core
end




function average_degree_f(fichier)

    f = open(fichier)
    degres, vraidegres, voisins = adjacency_a(fichier)
    n, m, inf = counting(fichier)
    # on utilise dans cette fonction que vraidegres et n

    m = sum(vraidegres)/(2*n)   # m : average degree density
    close(f)
    return m

    
end

function average_degree_f(fichier)

    f = open(fichier)
    degres, vraidegres, voisins = adjacency_a(fichier)
    n, m, inf = counting(fichier)
    # on utilise dans cette fonction que vraidegres et n

    m = sum(vraidegres)/(2*n)   # m : average degree density

    close(f)
    return m

    
end


function edge_density(fichier)

    f = open(fichier)

    n, a, inf = counting(fichier)

    ed = 2*a/(n*(n-1))   # ed : edge_density

    

    close(f)
    return ed
end

function select_core(fichier,p)

    

    f = open(fichier)
    c_max, liste_core = k_core(fichier)
    degres, liste_degres, voisins = adjacency_a(fichier)
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
    
    # on recupere tous les noeuds ayant un core egal a p
    for i in 1:n    # i = numero du noeud ; on parcours tous les noeuds
        #println("liste_core[i] = ", liste_core[i])
        #println("p = ", p)
        # on ajoute liste_core[i] a liste_select si le core du noeud i vaut p
        if liste_core[i] == p 
           
            #println("before")
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

   
    # nb_noeud = length(liste_select)
    println("nb_arete = ", nb_arete)
    println("nb_noeud = ", nb_noeud)
    # on connait le nombre d aretes et de noeuds du sous-graph, on peut donc calculer la densite moyenne
    # a = nb_arete/nb_noeud

    close(f)

    return list_density

end




#c, liste = k_core("amazon.txt")
#println("c = ", c)
#println("longueur_liste = ", length(liste))

#m = average_degree_f("amazon.txt")
#println("m = ", m)

#ed = edge_density("amazon.txt")
#println("ed = ", ed)

l = select_core("amazon.txt",8)
println("longueur_l = ", length(l))
println("max = ", maximum(l))
