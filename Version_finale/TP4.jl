
include("TP1.jl")
include("TP2.jl")
include("TP3.jl")
using StatsBase

"""
fonction de génération, exercice 1
"""
function generation(fichier, n, p, q)

    open(fichier, "w") do f
        for i in 1:n
            for j in i+1:n
                if mod(i-j, 4) == 0 # même communauté
                    if rand() < p
                        write(f, "$i $j\n")
                    end
                else
                    if rand() < q
                        write(f, "$i $j\n")
                    end
                end
            end
        end
    end
end

"""
mélange de Fisher-Yates, réindicé en Julia
"""
function FYS(tableau, n)
    for i in n:-1:2
        j = rand(1:i)
        tableau[i], tableau[j] = tableau[j], tableau[i]
    end
    return tableau
end

"""
à partir de la listes des labels, crée un dictionnaire avec les entrées des labels, 
puis renvoie le sous-dictionnaire des labels maximaux (et leur nombre)
"""
function freq_voisins(liste_labels)
    dict_labels = collect(countmap(liste_labels))
    # en tableau # dict_labels[i][1 | 2]
    n = length(dict_labels)

    trucs = [dict_labels[i][2] for i in 1:n] / sum([dict_labels[i][2] for i in 1:n])
    # println(trucs)
    M = maximum(trucs)
    a = findall(x -> x == M, trucs)
    return dict_labels[a]
end

"""
convertit un dictionnaire de type Int => Int en tableau ? x 2 associé
c'est plus facile de manipuler des tableaux
"""
function convert_dict_to_array(dictionnaire)
    n = length(dictionnaire)
    T = zeros(Int, n, 2)
    for i in 1:n
        T[i, 1], T[i, 2] = dictionnaire[i][1], dictionnaire[i][2]
    end
    return T
end

"""
effectue la vérification du test, on fait un parcours sur le graphe 
(l'article original / le cours ne semblent pas suggérer mieux)
"""
function test_validation(voisins, labels, n)
    
    bool = 1
    for i in 1:n
        li = labels[i]
        T = convert_dict_to_array(freq_voisins(labels[voisins[i]]))
        if size(T)[1] == 1 # un seul élément
            if li != T[1, 1]
                bool = 0
                break
            end
        else
            if li in T[:,1]
                continue
            else
                bool = 0
                break
            end
        end
    end
    return bool
end

"""
Label propagation
"""
function label_propagation(fichier)
    degres, vraidegres, voisins = adjacency_a(fichier)

    n = length(voisins)
    Labels = [i for i in 1:n]

    Niter = 0

    while Niter < 100 && test_validation(voisins, Labels, n) == 0
        # step 2
        ordre = FYS([i for i in 1:n], n)
        Niter += 1
        # println("ordre = $ordre")
        # println()
        # step 3
        for i in 1:n
            I = ordre[i]
            V = voisins[I]
            nv = length(V)

            dict_voisins = convert_dict_to_array(freq_voisins(Labels[V]))
            # println(Labels[I])
            if Labels[I] in dict_voisins[:,1] # déjà maximal
                continue
                indice = 0
            else
                if size(dict_voisins)[1] == 1 # un seul élément maximal
                    Labels[I] = dict_voisins[1][1]
                    indice = 1
                else
                    indice = rand(1:size(dict_voisins)[1])
                    Labels[I] = dict_voisins[indice][1]
                end
            end
            # println("dict voisins, ", dict_voisins)
            # println("indice, $indice")
            # freq
        end

        # println("Labels = $Labels")
    end

    return Labels, Niter
end


"""
légère modification pour traiter les graphes de type LFR
on traite une ligne de la forme    u v valeur
donc on parcourt le premier entier (1er while)
puis les espaces (2nd while)
puis le second entier (3eme while)
puis le reste n'est pas important
"""
function conversion_LFR(chaine)
    n = length(chaine)
    C1 = []
    C2 = []
    i = 1

    ci = chaine[i]
    while ci == '1' || ci == '2' || ci == '3' || ci == '4' || ci == '5' || ci == '6' || ci == '7' || ci == '8' || ci == '9' || ci == '0'
        i += 1
        ci = chaine[i]
    end
    I = i-1
    int1 = parse(Int,chaine[1:I])
    ci = chaine[i]

    while Int(ci) == 32 || Int(ci) == 9 || chaine[i] == "\t"
        i += 1
        ci = chaine[i]
    end
    I = i
    while ci == '1' || ci == '2' || ci == '3' || ci == '4' || ci == '5' || ci == '6' || ci == '7' || ci == '8' || ci == '9' || ci == '0'
        i += 1
        ci = chaine[i]
    end
    int2 = parse(Int,chaine[I:i-1])

    return int1, int2
end

"""
légère modification pour traiter les graphes de type LFR
"""
function counting_LFR(fichier)
    f = open(fichier)
    compteur_noeuds = 0
    compteur_aretes = 0
    test_0 = 1
    for ln in eachline(fichier)
        if ln[1] == '#' # on passe les lignes introductives des fichiers, par convention avec '# ...'
            continue
        end
        # println("$(ln),", ln[1])
        N1, N2 = conversion_LFR(ln)
        if max(N1, N2) > compteur_noeuds
            compteur_noeuds = max(N1, N2)
        end
        if min(N1, N2) < test_0
            test_0 = min(N1, n2)
        end
        compteur_aretes += 1
    end
    close(f)
    return compteur_noeuds, compteur_aretes, test_0
end

"""
légère modification pour traiter les graphes de type LFR
"""
function adjacency_a_LFR(fichier)
    n, m, inf = counting_LFR(fichier)
    f = open(fichier)
    # memory = 1
    degres = zeros(Int, n+1-inf)
    voisins = [[] for i in 1:n+1-inf] # si inf = 0, il y a le noeud 0 donc on rajoute un élément, sinon à 1 donc bien n
    if inf == 1 
        for ln in eachline(fichier)
            if ln[1] == '#'
                continue
            end
            N1, N2 = conversion_LFR(ln)
            
            degres[N1] += 1
            degres[N2] += 1
            push!(voisins[N1], (N2))
            push!(voisins[N2], (N1))
        end
    else ## l'indice 0 existe
        for ln in eachline(fichier)
            if ln[1] == '#'
                continue
            end
            N1, N2 = conversion_LFR(ln)

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



function label_propagation_LFR(fichier)
    degres, vraidegres, voisins = adjacency_a_LFR(fichier)

    n = length(voisins)
    Labels = [i for i in 1:n]

    Niter = 0
    # on met une limite arbitraire de 100 étapes, peut-être que cela peut bloquer la vraie terminaison pour de gros graphes...

    while Niter < 100 && test_validation(voisins, Labels, n) == 0
        # step 2
        ordre = FYS([i for i in 1:n], n)
        Niter += 1

        # step 3
        for i in 1:n
            I = ordre[i]
            V = voisins[I]
            nv = length(V)

            dict_voisins = convert_dict_to_array(freq_voisins(Labels[V]))

            if Labels[I] in dict_voisins[:,1] # déjà maximal
                continue
                indice = 0
            else
                if size(dict_voisins)[1] == 1 # un seul élément maximal
                    Labels[I] = dict_voisins[1][1]
                    indice = 1
                else
                    indice = rand(1:size(dict_voisins)[1])
                    Labels[I] = dict_voisins[indice][1]
                end
            end
        end
    end

    return Labels, Niter
end


"""
pour les fichiers du Benchmark de l'exercice 1, calcule la propagation de labels et l'inscrit à la fin du fichier (pour le code Python)
"""
function affichage(fichier)
    Labels, niter = label_propagation(fichier)
    uni_labels = unique(Labels)

    n = length(Labels)
    open(fichier, "a") do f
        write(f, "\n\n")
        write(f, "[")
        for i in 1:n-1
            ind = findfirst(x -> x == Labels[i], uni_labels)
            write(f, "\'$ind\', ")
        end
        ind = findfirst(x -> x == Labels[n], uni_labels)
            write(f, "\'$ind\'")
        write(f, "]")
    end
    
end

"""
pour les fichiers du Benchmark LFR, calcule la propagation de labels et l'inscrit à la fin du fichier (pour le code Python)
(il y a une subtilité dans le traitement)
"""
function affichage_LFR(fichier)
    Labels, niter = label_propagation_LFR(fichier)
    uni_labels = unique(Labels)

    n = length(Labels)
    open(fichier, "a") do f
        write(f, "\n\n")
        write(f, "[")
        for i in 1:n-1
            ind = findfirst(x -> x == Labels[i], uni_labels)
            write(f, "\'$ind\', ")
        end
        ind = findfirst(x -> x == Labels[n], uni_labels)
            write(f, "\'$ind\'")
        write(f, "]")
    end
    
end




"""
intersection de 2 listes d'entiers à la main, renvoie la liste aussi
"""
function hand_intersection2(L1, L2)
    compteur = 0
    l1 = length(L1)
    l2 = length(L2)
    L = []
    # println(l1, " et ", l2)
    if min(l1, l2) == 0
        return compteur, L
    end
    min1 = L1[1]
    min2 = L2[1]
    I1 = 1
    I2 = 1

    while I1 + I2 <= l1 + l2
        # println("$I1, $I2, $min1, $min2, $compteur")
        # println(I1+I2, " et ", l1 + l2)
        if min2 == min1
            compteur += 1
            push!(L, min2)
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
    return compteur, L
end

"""
V :  tableau des listes de voisins
VV : tableau des listes de voisins visités
n : taille
renvoie le prochain couple [i, vi] pas encore visités ; sert de restart pour l'exploration selon les triangles
"""
function find_prochain(V, VV, n)

    for i in 1:n
        if length(V[i]) > sum(VV[i]) # i-ième sommet encore à traiter
            return [i, V[i][findfirst(x -> x == 0, VV[i])] ]
        end
    end
    return [0, 0]
end

"""
fonction de 3-clique percolation (fonctionne ?)
"""
function ex_5_2(fichier)
    degres, vraidegres, Voisins = adjacency_a(fichier)
    n = length(degres)

    voisins_visites = [[] for i in 1:n]
    for i in 1:n
        voisins_visites[i] = zeros(Int, length(Voisins[i]))
    end

    compteur = 0 # compteur des cliques
    Clique = [[] for i in 1:n] # cliques
    M = sum(vraidegres) # 2 * m

    while sum([sum(voisins_visites[i]) for i in 1:n if length(voisins_visites[i]) > 0]) < M
        compteur += 1
        info = find_prochain(Voisins, voisins_visites, n)
        # println(info)

        # on récupère le prochain restart, dans les faits on regarde les composantes triangle-connexes
        
        LISTE = [[info[1], info[2]]]
        # Niter = 0

        while length(LISTE) > 0
            # Niter += 1
            # if mod(Niter, 1000) == 0
            #     println(Niter, " ", length(LISTE), " ", length(unique(LISTE)))
            # end
            edge = pop!(LISTE)
            sommet_courant = edge[1]
            voisin_courant = edge[2]
            
            I = findfirst(x -> x == voisin_courant, Voisins[sommet_courant])
            voisins_visites[sommet_courant][I] = 1
            I = findfirst(x -> x == sommet_courant, Voisins[voisin_courant])
            voisins_visites[voisin_courant][I] = 1
            # on visite les voisins

            nb, L = hand_intersection2(Voisins[sommet_courant], Voisins[voisin_courant])
            if nb == 0
                compteur -= 1 # correction car on a augmenté pour rien ; "marche" parce que comme on a tous les sommets, l'intersection est vide uniquement 
                continue # pour les arêtes de transition
            else
                if (compteur in Clique[sommet_courant]) == 0
                    push!(Clique[sommet_courant], compteur)
                end
                if (compteur in Clique[voisin_courant]) == 0
                    push!(Clique[voisin_courant], compteur)
                end

                for troisieme in reverse(L)
                    Is = findfirst(x -> x == troisieme, Voisins[sommet_courant])
                    Iv = findfirst(x -> x == troisieme, Voisins[voisin_courant])
                    if voisins_visites[sommet_courant][Is] == 1 || voisins_visites[voisin_courant][Iv] == 1
                        continue
                    end
                    voisins_visites[sommet_courant][Is] = 1
                    voisins_visites[voisin_courant][Iv] = 1

                    Is = findfirst(x -> x == sommet_courant, Voisins[troisieme])
                    Iv = findfirst(x -> x == voisin_courant, Voisins[troisieme])
                    if voisins_visites[troisieme][Is] == 1 || voisins_visites[troisieme][Iv] == 1
                        continue
                    end
                    voisins_visites[troisieme][Is] = 1
                    voisins_visites[troisieme][Iv] = 1
                    # ne pas boucler et remettre les mêmes arêtes


                    if (compteur in Clique[troisieme]) == 0 # test pour ne pas mettre tout le temps les mêmes, peut-être que juste les rajouter et trier à la fin est plus rapide
                        push!(Clique[troisieme], compteur)
                    end
                    push!(LISTE, [voisin_courant, troisieme])
                    push!(LISTE, [sommet_courant, troisieme])
                    # mise à jour de la pile
                end
            end
        end
        # println("compteur = $compteur, Niter = $Niter")
    end

    return Clique
end
