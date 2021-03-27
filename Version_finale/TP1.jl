

"""
passe d'une chaine '??? ???' aux deux entiers correspondants
"""
function conversion(chaine)
    n = length(chaine)
    C1 = []
    C2 = []
    for i in 1:n
        if chaine[i] == '1' || chaine[i] == '2' || chaine[i] == '3' || chaine[i] == '4' || chaine[i] == '5' || chaine[i] == '6' || chaine[i] == '7' || chaine[i] == '8' || chaine[i] == '9' || chaine[i] == '0'
            continue
        else
            C1 = chaine[1:i-1]
            C2 = chaine[i+1:n]
        end
    end
    return parse(Int,C1), parse(Int,C2)
end

"""
fonction de comptage des noeuds / arêtes
"""
function counting(fichier)
    f = open(fichier)
    compteur_noeuds = 0
    compteur_aretes = 0
    test_0 = 1
    for ln in eachline(fichier)
        if length(ln) == 0 || length(ln) == 1 || ln[1] == '#' || ln[1] == '[' # on passe les lignes introductives des fichiers, par convention avec '# ...'
            continue
        end
        # println("$(ln),", ln[1])
        N1, N2 = conversion(ln)
        if max(N1, N2) > compteur_noeuds
            compteur_noeuds = max(N1, N2)
        end
        if min(N1, N2) < test_0
            test_0 = min(N1, N2)
        end
        compteur_aretes += 1
    end
    close(f)
    return compteur_noeuds, compteur_aretes, test_0
end


"""
fonction de liste d'arêtes, renvoyée comme matrice 
"""
function edge_list(fichier)
    f = open(fichier)
    liste = []
    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        N1, N2 = conversion(ln)
        pushfirst!(liste, (N1, N2))
    end
    close(f)
    m = length
    return liste[length(liste):-1:1]
end


"""
fonction de matrice d'adjacence
"""
function adjacency_m(fichier)
    n, m, inf = counting(fichier)
    f = open(fichier)

    M = zeros(n+1-inf,n+1-inf) # si inf = 0, il y a le noeud 0 donc on rajoute un élément, sinon à 1 donc bien n

    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        N1, N2 = conversion(ln)
        if N1 > 0
            M[N1, N2] = 1
            M[N2, N1] = 1
        else# arêtes partant de 0
            M[end, N2] = 1
            M[N2, end] = 1
        end
    end
    close(f)
    return M
end

"""
fonction de tableau d'adjacence
"""
function adjacency_a(fichier)
    n, m, inf = counting(fichier)
    f = open(fichier)
    degres = zeros(Int, n+1-inf)
    voisins = [[] for i in 1:n+1-inf] # si inf = 0, il y a le noeud 0 donc on rajoute un élément, sinon à 1 donc bien n
    if inf == 1 
        for ln in eachline(fichier)
            if length(ln) == 0 || ln[1] == '#' || length(ln) == 1 || ln[1] == '['
                continue
            end
            N1, N2 = conversion(ln)
            
            degres[N1] += 1
            degres[N2] += 1
            push!(voisins[N1], (N2))
            push!(voisins[N2], (N1))
        end
    else ## l'indice 0 existe
        for ln in eachline(fichier)
            if length(ln) == 0 || ln[1] == '#' || length(ln) == 1 || ln[1] == '['
                continue
            end
            N1, N2 = conversion(ln)

            degres[N1+1] += 1
            degres[N2+1] += 1
            push!(voisins[N1+1], N2+1)
            push!(voisins[N2+1], N1+1)
        end
    end

    vraidegres = copy(degres)
    degres = cumsum(degres)
    close(f)
    return degres, vraidegres, voisins
end


"""
BFS, avec node un entier, version basique comptant la distance pour des poids de 1
"""
function BFS(degres, vraidegres, voisins, node)
    F = []
    # degres, vraidegres, voisins = adjacency_a(filename)
    
    n = length(degres)
    distances = -1 * ones(n)
    distances[node] = 0
    parent = 0 * ones(n)
    parent[node] = node

    push!(F, node)
    marks = zeros(n)
    marks[node] = 1
    if node > n
        println("Error in node number")
        return
    end

    while length(F) > 0
        u = popfirst!(F)
        for v in voisins[u]
            if marks[v] == 1
                continue
            else
                marks[v] = 1
                parent[v] = u
                distances[v] = distances[u] + 1
                push!(F, v)
            end
        end
    end
    return distances
end

"""
Utilisation du BFS
"""

function lowerbound(filename)
    degres, vraidegres, voisins = adjacency_a(filename)
    Node, MaxDeg = (argmax(vraidegres), maximum(vraidegres)) # utiles pour la suite
    # on part du point de degré maximal
    n = length(degres)
    marks = zeros(n)
    # nombre arbitraire "raisonnable" (?) de parcours
    S = Int(2*ceil(log10(n)))
    
    nb_iter = 0
    Maxdist = 0
    while nb_iter < S
        Dist = BFS(degres, vraidegres, voisins, Node)
        marks[Node] = 1
        Node, Maxdist = (argmax(Dist), max(maximum(Dist), Maxdist))
        nb_iter += 1
        if marks[Node] == 1 # on a déjà vu
            Node = rand(1:n)
            while length(voisins[Node]) == 0
                Node = rand(1:n)
            end
        end
    end
    return Maxdist
end


function upperbound(filename)
    degres, vraidegres, voisins = adjacency_a(filename)
    Node, MaxDeg = (argmax(vraidegres), maximum(vraidegres)) # utiles pour la suite

    # Node est un "noeud central"
    Dist = BFS(degres, vraidegres, voisins, Node)
    
    N1, D1 = (argmax(Dist), maximum(Dist))
    popat!(Dist, N1) # on retire l'élément maximal
    N2, D2 = (argmax(Dist), maximum(Dist))
    return D1 + D2
end


"""
fonction d'intersection, cf commentaire Ophélie Bleu
"""
function hand_intersection(L1, L2)
    compteur = 0
    l1 = length(L1)
    l2 = length(L2)
    if min(l1, l2) == 0
        return 0
    end
    min1 = L1[1]
    min2 = L2[1]
    I1 = 1
    I2 = 1
    while I1 + I2 <= l1 + l2
        if min2 == min1
            compteur += 1
            I1 = I1+1
            I2 = I2+1
            min1 = L1[min(l1, I1)]
            min2 = L2[min(l2, I2)]
        elseif min2 == min1 
        elseif I2 == l2 && min2 < min1 # terminé pour L2
            break
        elseif I1 == l1 && min1 < min2 # terminé pour L1
            break
        elseif I2 < l2 && min2 < min1
            while min2 < min1 && I2 < l2
                I2 += 1
                min2 = L2[I2]
            end
        elseif min1 < min2 && I1 < l1
            while min1 < min2 && I1 < l1
                I1 += 1
                min1 = L1[I1]
            end
        else # cas terminal, 
            break
        end
    end
    return compteur
end


function building_testlist(n)
    L = []
    for i in 1:n
        r = rand()
        if r > 0.9
            push!(L, i)
        end
    end
    return L
end

"""
obtention des triangles dans le graphe
"""
function triangles(filename)
    degres, vraidegres, voisins = adjacency_a(filename)
    n = length(degres)
    Permu_degre = sortperm(vraidegres)[n:-1:1] # permutation du tri selon les degres, ordre décroissant
    INV_perm_d = invperm(Permu_degre)
    N_tri = 0

    Degres = vraidegres[Permu_degre]
    Voisins = [[] for i in 1:n]
    # renommage du graphe
    for i in 1:n
        for voisin in voisins[Permu_degre[i]]
            push!(Voisins[i], INV_perm_d[voisin])
        end
    end

    ## ici les voisins sont renommés mais pas ordonnés, ce qu'on fait
    for Voisin in Voisins
        sort!(Voisin)
    end

    # # # on tronque aux voisins supérieurs
    for i in 1:n
        # println(Voisins[i], "debut ")
        while length(Voisins[i]) > 0 && Voisins[i][1] < i
            popfirst!(Voisins[i])
            # println(Voisins[i])
        end
    end

    # maintenant on a bien un graphe renommé, qui a un degré décroissant, 
    # et dont on considère uniquement les voisins supérieurs, i.e. le nombre total
    # d'éléments est bien m et pas 2m

    for i in 1:n # boucle sur les sommets
        for voisin in Voisins[i] # par définition, une arête va apparaître une et une seule fois dans ce "nouveau (faux) graphe"
            # N_tri += length(intersect(Voisins[i], Voisins[voisin])) # taille de l'intersection
            N_tri += hand_intersection(Voisins[i], Voisins[voisin])
        end
    end
    return N_tri
end

## sans le prétraitement
function triangles2(filename)
    degres, vraidegres, voisins = adjacency_a(filename)
    n = length(degres)
    N_tri = 0
    for i in 1:n
        if length(voisins[i]) > 0
            for voisin in voisins[i]
                if voisin < i
                    continue
                else
                    # N_tri += length(intersect(voisins[i], voisins[voisin]))
                    N_tri += hand_intersection(voisins[i], voisins[voisin])
                end
            end
        end
    end
    # return N_tri
    return Int(N_tri/3)
end