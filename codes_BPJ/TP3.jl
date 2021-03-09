using Statistics
using LinearAlgebra
using Plots

include("TP1.jl")

include("memory_cats.jl")
include("memory_nodes.jl")
include("memory_nodes_clean.jl")

"""
réalise la multiplication entre une liste de coordonnées / valeurs (tableau 3 * m) et un vecteur de taille n
dans les faits, si on a u -> v, le coefficient non-nul est bien en T_{vu} car c'est v qui récupère de la masse depuis u
dans la fonction on utilise la convention usuelle i, j
"""
function multiplication(liste_ind, liste_v, m, P, n)

    Pp = zeros(n)
    for edge in 1:m
        i, j= liste_ind[edge, :]
        v = liste_v[edge]
        Pp[i] += v * P[j]
    end
    return Pp
end


"""
retourne la taille des informations et la liste / matrice T
"""
function traitement(fichier)
    f = open(fichier)
    
    # compteur_noeuds, compteur_aretes, inf = counting(fichier)
    # degres, vraidegres, voisins = adjacency_a(fichier)
    # compteur_noeuds = length(voisins)
    # compteur_aretes = Int(degres[end]/2)
    # compteur_noeuds = 0
    # compteur_aretes = countlines(fichier) - 2
    # println("countlines terminé")
    # Tind = zeros(Int, 0, 2)
    # Tv = zeros(0, 1)
    # T_local_ind = zeros(Int, 0, 2)
    # T_local_v = zeros(0, 1)

    compteur_aretes = countlines(fichier)-2 # "second" passage mais rapide , -2 pour enlever les lignes de commentaires
    Tind = zeros(Int, compteur_aretes, 2)
    Tv = ones(compteur_aretes, 1)
    
    Info_noeuds = zeros(compteur_aretes+1, 1) ### stupide mais pour éviter de parcourir 2 fois le fichier
    IN = zeros(compteur_aretes+1)
    OUT = zeros(compteur_aretes+1)


    memory_N1 = -1
    compteur_local = 0
    compteur_aretes = 0
    compteur_noeuds = 0

    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        # if mod(compteur_aretes, 10000) == 0
        #     println(compteur_aretes)
        # end
        compteur_aretes += 1
        N1, N2 = conversion(ln)

        OUT[N1] += 1
        IN[N2] += 1

        compteur_noeuds = max(compteur_noeuds, N1, N2)
        Tind[compteur_aretes, :] = [N1; N2]
        
        # les noeuds N1, N2 font bien partie du graphes et ne sont pas des objets intermédiaires
        Info_noeuds[N1] += 1
        Info_noeuds[N2] += 1

        if N1 != memory_N1 # nouveau noeud avec ses successeurs
            memory_N1 = N1
            # T_local_v /= compteur_local # diviser par le degré, pour les noeuds ayant des successeurs
            # Tv = [Tv; T_local_v]
            # Tind = [Tind; T_local_ind]
            # T_local_ind = [N1 N2]
            # T_local_v = [1.0]
            Tv[compteur_aretes-compteur_local:compteur_aretes-1] /= compteur_local
            compteur_local = 1
        else
            compteur_local += 1
            # T_local_ind = [T_local_ind; [N1 N2]]
            # T_local_v = [T_local_v; 1.0]
        end

    end
    # une dernière fois pour la dernière valeur de N1
    # Tv = [Tv; T_local_v / compteur_local]
    # Tind = [Tind; T_local_ind]
    Tv[compteur_aretes-compteur_local:compteur_aretes] /= compteur_local

    return compteur_noeuds, compteur_aretes, Tind, Tv, Info_noeuds[1:compteur_noeuds], IN[1:compteur_noeuds], OUT[1:compteur_noeuds]
end


function PageRank(fichier, alpha, t)

    n, m, Tind, Tv, info, In_T, Out_T = traitement(fichier)
    println("traitement terminé")

    real_nodes = ifelse.(info .>= 1, 1, 0)
    real_nodes /= sum(real_nodes) # remplace le I
    P = real_nodes
    oldP = zeros(length(P))
    variations = zeros(t)
    for time in 1:t
        P = multiplication(Tind, Tv, m, P, n) # fait la multiplication entre une liste de coordonnées et un vecteur
        P = (1 - alpha) * P + alpha * real_nodes
        P += real_nodes * (1 - sum(P))/n
        valeur = log(norm(P - oldP))
        println("itération $time")
        println("itération $time, value = $valeur")
        variations[time] = log10(norm(P - oldP))
        oldP = P
    end
    println(maximum(P))
    println(std(P))
    display(plot([i for i in 1:t], variations, label = "logarithme de la norme de la variation"))
    png("norme_variation.png")
    return P
end

function maxk!(ix, a, k; initialized=false)
    partialsortperm!(ix, a, 1:k, rev=true, initialized=initialized)
    return collect(zip(ix[1:k], a[ix[1:k]]))
end

# function mink!(ix, a, k; initialized=false)
#     partialsortperm!(ix, a, 1:k, initialized=initialized)
#     return collect(zip(ix[1:k], a[ix[1:k]]))
# end

"""
convertit une chaine de type "indice_noeud      nom_page" en
l'indice et le nom de la page
"""
function conversion2(chaine)
    n = length(chaine)
    C1 = []
    C2 = []
    for i in 1:n
        # println("dans conversion2, truc puis int(truc)")
        # println(chaine[i], " ", Int(chaine[i]))

        if chaine[i] == '1' || chaine[i] == '2' || chaine[i] == '3' || chaine[i] == '4' || chaine[i] == '5' || chaine[i] == '6' || chaine[i] == '7' || chaine[i] == '8' || chaine[i] == '9' || chaine[i] == '0'
            continue
        elseif Int(chaine[i]) == 32 || Int(chaine[i]) == 9 || chaine[i] == "\t" ## espace
            C1 = chaine[1:i-1]
            C2 = chaine[i+1:end]
            break
        else
            println("erreur de typage dans la chaine")
            println(chaine)
            break
        end
    end
    return parse(Int,C1), C2
end

# fonction de test, pas utile
function TRESTE(fichier)
    for ln in eachline(fichier)
        if length(ln) == 0 || ln[1] == '#'
            continue
        end
        # println("\n")
        # println(ln)
        id, nom = conversion2(ln)
        # println("id = $id, nom = $nom")
    end
end


function fin_exercice_1(fichier, info_fichier)
    page_ranks = PageRank(fichier, 0.15, 20)
    n = length(page_ranks)
    autre_page_rank = zeros(n)

    autre_page_rank = ifelse.(page_ranks .== 0, -1, -page_ranks)

    idx = collect(1:length(page_ranks))
    trucs_M = maxk!(idx, page_ranks, 5, initialized = true)

    idx = collect(1:length(page_ranks))
    trucs_m = maxk!(idx, autre_page_rank, 5, initialized = true)

    print(trucs_m)
    list_pages_M = []
    list_pages_m = []

    for ln in eachline(info_fichier)

        if length(ln) == 0 || ln[1] == '#'
            continue
        end

        indice, nom = conversion2(ln)
        for j in 1:5
            if indice == trucs_M[j][1]
                push!(list_pages_M, nom)
            elseif indice == trucs_m[j][1]
                push!(list_pages_m, nom)
            end
        end
    end
    return list_pages_M, list_pages_m
end

function perso_PageRank(fichier, indice, alpha, t)

    n, m, Tind, Tv, info, In_T, Out_T = traitement(fichier)

    println("traitement terminé")

    real_nodes = ifelse.(info .>= 1, 1, 0)
    real_nodes /= sum(real_nodes) # remplace le I
    P = real_nodes
    ## même chose jusqu'ici
    ## construction de P0
    P0 = zeros(length(real_nodes))
    P0[indice] = 1
    # version avec un indice, possible de faire des choses différentes  

    for time in 1:t
        P = multiplication(Tind, Tv, m, P, n) # fait la multiplication entre une liste de coordonnées et un vecteur
        P = (1 - alpha) * P + alpha * P0

        P += P0 * (1 - sum(P))/n # on vectorise la ligne de calcul 
    end
    return P, sum(ifelse.(real_nodes .== 0, 0, 1))
end



function in_out(fichier)
    n, m, inf = counting(fichier)
    IN = zeros(Int, n)
    OUT = zeros(Int, n)

    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        N1, N2 = conversion(ln)
        OUT[N1] += 1
        IN[N2] += 1
    end

    return IN, OUT
end


function courbes(fichier, list_alpha, t)
    n, m, Tind, Tv, info, In, Out = traitement(fichier)
    println("traitement terminé")

    nb_trucs = length(list_alpha)

    real_nodes = ifelse.(info .>= 1, 1, 0)
    println("sum real nodes = $(sum(real_nodes)) ")
    real_nodes /= sum(real_nodes) # remplace le I
    Values = zeros(n, nb_trucs)
    println("n = $n")
    println("m = $m")
    for a in 1:nb_trucs
        P = real_nodes
        alpha = list_alpha[a]
        for time in 1:t
            P = multiplication(Tind, Tv, m, P, n) # fait la multiplication entre une liste de coordonnées et un vecteur
            P = (1 - alpha) * P + alpha * real_nodes
            P += real_nodes * (1 - sum(P))/n
            println("value alpha = $alpha, itération $time")
        end
        Values[:, a] = P
    end
    # PLOT1 = plot(log10.(Values[:, 2]), In, label="degré entrant selon le PageRank")
    # display(PLOT1);
    # png("plot_num_1")
    # println("plot terminé")
    # PLOT2 = plot(log10.(Values[:, 2]), Out, label="degré sortant selon le PageRank")
    # display(PLOT2);
    # png("plot_num_2")
    # println("plot terminé")
    # PLOT3 = plot(log10.(Values[:, 2]), log10.(Values[:, 1]), label="PR 0.1 en fonction du PR 0.15")
    # display(PLOT3);
    # png("plot_num_3")
    # println("plot terminé")
    # PLOT4 = plot(log10.(Values[:, 2]), log10.(Values[:, 3]), label="PR 0.1 en fonction du PR 0.2")
    # display(PLOT4);
    # png("plot_num_4") 
    # println("plot terminé")
    # PLOT5 = plot(log10.(Values[:, 2]), log10.(Values[:, 4]), label="PR 0.1 en fonction du PR 0.5")
    # display(PLOT5);
    # png("plot_num_5")
    # println("plot terminé")
    # PLOT6 = plot(log10.(Values[:, 2]), log10.(Values[:, 5]), label="PR 0.1 en fonction du PR 0.9")
    # display(PLOT6);
    # png("plot_num_6")
    # println("plot terminé")
    return Values, In, Out
end

function pythonisation(T1, T2, T3, T4, T5, T6, T7, n)
    open("trucs_python.py", "w") do f
        write(f, "import numpy as np\n\n")
        write(f, "PR010 = np.array([")
        for i in 1:n-1
            if T1[i] > 0
                write(f, "$(T1[i]), ")
            end
        end
        if T1[n] > 0
            write(f, "$(T1[n])])\n\n")
        end
        # T1
        write(f, "PR015 = np.array([")
        for i in 1:n-1
            if T2[i] > 0
                write(f, "$(T2[i]), ")
            end
        end
        if T2[n] > 0
            write(f, "$(T2[n])])\n\n")
        end
        # T2

        write(f, "PR020 = np.array([")
        for i in 1:n-1
            if T3[i] > 0
                write(f, "$(T3[i]), ")
            end
        end
        if T3[n] > 0
            write(f, "$(T3[n])])\n\n")
        end

        write(f, "PR050 = np.array([")
        for i in 1:n-1
            if T4[i] > 0
                write(f, "$(T4[i]), ")
            end
        end
        if T4[n] > 0
            write(f, "$(T4[n])])\n\n")
        end

        write(f, "PR090 = np.array([")
        for i in 1:n-1
            if T5[i] > 0
                write(f, "$(T5[i]), ")
            end
        end
        if T5[n] > 0
            write(f, "$(T5[n])])\n\n")
        end

        write(f, "Ind = np.array([")
        for i in 1:n-1
            if T6[i] + T7[i] > 0
                write(f, "$(T6[i]), ")
            end
        end
        if T6[n] + T7[n] > 0
            write(f, "$(T6[n])])\n\n")
        end

        # le test T6 + T7 > 0 signifie que le noeud i a au moins un noeud entrant / sortant donc est un vrai noeud 
        # il faut sommer les deux pour ne pas mal traiter les noeuds n'ayant que des successeurs / prédécesseurs
        write(f, "Outd = np.array([")
        for i in 1:n-1
            if T7[i] + T6[i] > 0
                write(f, "$(T7[i]), ")
            end
        end
        if T6[n] + T7[n] > 0
            write(f, "$(T7[n])])\n\n")
        end
    end
    return 
end

function plot_treatment(T1, T2, T3, T4, T5, T6, T7, n)
    
    C = 0
    for i in 1:n
        if T6[i] + T7[i] > 0
            C += 1
        end
    end
    TT2 = zeros(C)
    TT1 = zeros(C)
    TT3 = zeros(C)
    TT4 = zeros(C)
    TT5 = zeros(C)
    TT6 = zeros(C)
    TT7 = zeros(C)

    C = 0

    # le test T6 + T7 > 0 signifie que le noeud i a au moins un noeud entrant / sortant donc est un vrai noeud 
    # il faut sommer les deux pour ne pas mal traiter les noeuds n'ayant que des successeurs / prédécesseurs

    for i in 1:n
        if T7[i] + T6[i] > 0 # vrai noeud
            C += 1 # indice dans le tableau avec les vrais noeuds
            TT1[C] = log10(T1[i])
            TT2[C] = log10(T2[i])
            TT3[C] = log10(T3[i])
            TT4[C] = log10(T4[i])
            TT5[C] = log10(T5[i])
            if T6[i] > 0
                TT6[C] = log10(T6[i])
            else
                TT6[C] = -1
            end
            if T7[i] > 0
                TT7[C] = log10(T7[i])
            else
                TT7[C] = -1
            end
        end
    end
    return TT1, TT2, TT3, TT4, TT5, TT6, TT7
end









"""
renvoie les ID de "Chess" et "Boxing", (usage unique)
"""
function chess_boxing_ID_cat(fichier)

    chess_IDs = []
    boxing_IDs = []

    for ln in eachline(fichier)
        if length(ln) == 0 || ln[1] == '#'
            continue
        end

        id, nom = conversion2(ln)
        if occursin("chess", nom) || occursin("Chess", nom)
            append!(chess_IDs, id)
        elseif occursin("boxing", nom) || occursin("Boxing", nom)
            append!(boxing_IDs, id)
        end
    end

    open("memory_cats.jl", "w") do f
        write(f, "memory_chess = [")
        for i in 1:length(chess_IDs)-1
            write(f, "$(chess_IDs[i]), ")
        end
        write(f, "$(chess_IDs[end])]\n")

        write(f, "memory_boxing = [")
        for j in 1:length(boxing_IDs)-1
            write(f, "$(boxing_IDs[j]), ")
        end
        write(f, "$(boxing_IDs[end])]\n")
    end
    # return chess_IDs, boxing_IDs
end

"""
conversion pour le fichier des catégories (usage "unique")
"""
function conversion3(chaine)
    n = length(chaine)
    C1 = []
    Vec_chaine = []

    C = 1
    while C <= n && (chaine[C] == '1' || chaine[C] == '2' || chaine[C] == '3' || chaine[C] == '4' || chaine[C] == '5' || chaine[C] == '6' || chaine[C] == '7' || chaine[C] == '8' || chaine[C] == '9' || chaine[C] == '0')
        C += 1
    end
    C1 = chaine[1:C-1]
    # maintenant on passe au reste de la ligne
    while C <= n
        # on vire les espaces potentiels
        while Int(chaine[C]) == 32 || Int(chaine[C]) == 9 || chaine[C] == "\t" 
            C += 1
        end
        mem_C = C
        while C <= n && (chaine[C] == '1' || chaine[C] == '2' || chaine[C] == '3' || chaine[C] == '4' || chaine[C] == '5' || chaine[C] == '6' || chaine[C] == '7' || chaine[C] == '8' || chaine[C] == '9' || chaine[C] == '0')
            C += 1
        end
        append!(Vec_chaine, [chaine[mem_C:C-1]])
    end
    return parse(Int, C1), Vec_chaine
end

"""
crée un fichier disant quels noeuds sont dans les catégories "Chess" et "Boxing", usage unique
utilise le résultat de la fonction chess_boxing_ID_cat
[pourrait l'appeler mais comme elle est à usage unique, on utilise directement le résultat]
"""
function chess_boxing_memory(fichier)
    Chess_list = []
    Boxing_list = []

    compteur = 0
    for ln in eachline(fichier)

        if length(ln) == 0 || ln[1] == '#'
            continue
        end
        compteur += 1
        if mod(compteur, 100000) == 0
            println(compteur)
        end
        C, VC = conversion3(ln)

        if compteur > 2590 && compteur < 2605
            println(ln)
            println(C)
            println(VC)
        end

        for j in 1:length(VC)
            if parse(Int, VC[j]) in memory_chess
                push!(Chess_list, C)
            elseif parse(Int, VC[j]) in memory_boxing
                push!(Boxing_list, C)
            end
        end
    end

    open("memory_nodes.jl", "w") do f
        write(f, "nodes_chess = [")
        for i in 1:length(Chess_list)-1
            write(f, "$(Chess_list[i]), ")
        end
        write(f, "$(Chess_list[end])]\n")

        write(f, "ndoes_boxing = [")
        for j in 1:length(Boxing_list)-1
            write(f, "$(Boxing_list[j]), ")
        end
        write(f, "$(Boxing_list[end])]\n")
    end

    # return Chess_list, Boxing_list
end

"""
les noeuds sont doublés dans les tableau précédents, on applique la fonction "unique" [les tableaux sont de taille raisonnable]
aussi à usage unique
"""
function purge()
    nodes_chess_c = unique(nodes_chess)
    nodes_boxing_c = unique(nodes_boxing)
    nc = length(nodes_chess_c)
    nb = length(nodes_boxing_c)

    open("memory_nodes_clean.jl", "w") do f
        write(f, "nodes_chess_cleaned = [")
        for i in 1:length(nodes_chess_c)-1
            write(f, "$(nodes_chess_c[i]), ")
        end
        write(f, "$(nodes_chess_c[end])]\n")

        write(f, "ndoes_boxing_cleaned = [")
        for j in 1:length(nodes_boxing_c)-1
            write(f, "$(nodes_boxing_c[j]), ")
        end
        write(f, "$(nodes_boxing_c[end])]\n")
    end

end


function courbe_ex3(fichier, alpha, t)

    # on donne directement l'indice associé à Magnus Carlsen
    MC_PR, nn = perso_PageRank(fichier, 442682, alpha, t)
    println("PageRank terminé")
    vrais_PR = zeros(nn)
    indices = zeros(nn)
    C = 0
    for i in 1:length(MC_PR)
        if MC_PR[i] > 0
            C += 1
            vrais_PR[C] = MC_PR[i]
            indices[C] = i
        end
    end
    ## récupération des valeurs non-nulles, donc des vrais noeuds
    println("purge terminée ", C)
    permutation = sortperm(vrais_PR, rev=true)
    println("permutation terminée")
    nombre_echecs = zeros(nn+1)
    new_indices = indices[permutation]
    for i in 1:nn
        if mod(i, 200000) == 0
            println(i, " ")
        end
        if new_indices[i] in nodes_chess_cleaned
            nombre_echecs[i+1] = nombre_echecs[i] + 1
        else
            nombre_echecs[i+1] = nombre_echecs[i]
        end
    end

    nombre_echecs = nombre_echecs[2:end] # on enlève la première valeur simplement pour simplifier le calcul
    vrais_PR = vrais_PR[permutation]
    println("calcul terminé")
    
    l = @layout [a ; b]

    # p1 = plot(vrais_PR, label = "PageRank en Magnus Carlsen", xaxis=:log, yaxis=:log, fillto=1e-8)
    # png("PR_MC.png")
    println("premier plot terminé (?)")

    # p2 = plot(nombre_echecs, label = "Nombre de noeuds des catégories échec", xaxis=:log, fillto=1e-8)
    # png("image_2.png")
    # println("second plot terminé (?)")
    # display(plot(p1, p2, layout = l))
    # println("assemblage terminé (?)")
    # sleep(120)
    # savefig("image_ex3.png")

    open("trucs_python2.py", "w") do f
        write(f, "import numpy as np\n\n")
        write(f, "vrais_PR = np.array([")
        for i in 1:nn-1
            write(f, "$(vrais_PR[i]), ")
        end
        write(f, "$(vrais_PR[nn])])\n\n")

        write(f, "nombre_echecs = np.array([")
        for i in 1:nn-1
            write(f, "$(nombre_echecs[i]), ")
        end
        write(f, "$(nombre_echecs[nn])])\n\n")

        write(f, "permutation = np.array([")
        for i in 1:nn-1
            write(f, "$(permutation[i]), ")
        end
        write(f, "$(permutation[nn])])\n\n")
    end
end


