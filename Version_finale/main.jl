using Random
using StatsBase
using Plots


### lien github https://github.com/maxdan94/LoadGraph

include("TP1.jl")
include("TP2.jl")
include("TP3.jl")
include("TP4.jl")

## première application

# filename = "data/basic.txt"
# filename = "data/basic0.txt"
# filename = "data/basic_vide.txt"
# filename = "data/ex_cours.txt"
# filename = "data/test_cours.txt"
# filename = "data/com-amazon.txt"
# filename = "data/com-lj.txt"
# filename = "data/com-orkut.txt"
# filename = "data/com-friendster.txt"

##### TP1
### ex 1
# fonction comptant le noeuds / arêtes du graphe
# @time counting(filename)
# println("passage après comptage")
### ex 2
# # # fonction en liste d'arêtes
# @time edge_list(filename)
# println("passage après liste")
# # # # # fonction en matrice d'adjacence
# # # # # # # # # # # # # # # # @time adjacency_m(filename)
# # # # # # # # # # # # # # # # println("passage après matrice")
# # # # # fonction en tableau d'adjacence
# @time adjacency_a(filename)
# println("terminé")

# # ### ex 3
# node = 2
# a, b, c = adjacency_a(filename)
# @time BFS(a, b, c, node)

# println("passage après array")
# @time println(lowerbound(filename))
# @time println(upperbound(filename))
# println("passage après bornes")
# # ### ex 4

# @time println(triangles(filename))
# @time println(triangles2(filename))

# println(hand_intersection([5, 7, 8, 9, 11, 15, 16, 17, 19, 20], [4, 5, 6, 8, 9, 10, 12, 13, 15, 18, 19, 20]))

#######################################################################################################################################
#=
##### TP2
# ------------------- PARAMETRES UTILISATEUR -----------------------------------

# informations lors de l execution des fonctions k_core et density_prefix
informations_core = 1
informations_density = 1

# --------- Parametres exercice 1
# ex1 = 1 -> Simulations pour l exercice 1
ex1 = 1     

# nom du fichier dont on veut extraire les informations
fichier1 = "amazon.txt"

# nom du fichier dans lequel on enregistre le Plot pour les densites
nom_fichier_plot_add = "Plot amazon.txt - degree density prefix - 25.03"
nom_fichier_plot_ed = "Plot amazon.txt - edge density prefix - 25.03"

# si av_degree_edge_density = 1, on calcul le av_degree_edge_density
av_degree_edge_density = 1

# si plot = 1, on trace le average degree density prefix
plot1 = 1


# ---------- Parametres exercice 2
# ex2 = 1 -> Simulations pour l exercice 2
ex2 = 1

# nom du fichier dont on veut extraire les informations
fichier2 = "net.txt"
fichier_ID = "ID.txt"

# nom du fichier dans lequel on enregistre le Plot du core en fonction des degres
nom_fichier_plot_core_degre = "Plot net.txt - core_degre - 26.03"

# ratio core/degre a partir duquel il on considere un noeud comme etant anormal
ratio = 15


# ------------------- EXERCICE 1 -----------------------------------

if ex1 == 1

    println("Debut exercice 1")

    # argument -> fichier texte dont est inscrit le graphe
    # return -> liste_degres : liste de taille nb_noeud qui donne a chaque numéro de noeud son degres
    degres, liste_degres, voisins = adjacency_a(fichier1)
    n = length(liste_degres)


    println("degre maximal = ", maximum(liste_degres))
    n = length(liste_degres)
    println("nombre de noeud = ", n)



    # argument -> fichier texte dont est inscrit le graphe
    # return -> 
    # c_max : core maximum du graphe
    # liste_core : liste de taille nb_noeud qui donne a chaque numéro de noeud son core
    # ordre_noeud : liste de taille nb_noeud qui donne a chaque numéro de noeud son ordre de passage selon le core
    # tri_noeud : liste de taille nb_noeud qui donne a chaque entier le noeud dont l'ordre de passage selon le core est cet entier (fonction inverse de liste_core)
    println("debut calcul core")
    @time c_max, liste_core, ordre_noeud, tri_noeud = k_core(fichier1, informations_core)
    println("fin calcul core")
    println(" ")
    println("core maximal = ", c_max)
    println(" ")


    if av_degree_edge_density == 1

        println("debut calcul densite")
        max_add, size_max_add, liste_add, max_ed, size_max_ed, liste_ed = density_prefix(fichier1, ordre_noeud, tri_noeud, informations_density)
        println("fin calcul densite")
        println(" ")
        println("highest average degree density prefix = ", max_add)
        println("size of the subgraph with the highest average degree density prefix = ", size_max_add)
        println("highest edge density prefix = ", max_ed)
        println("size of the subgraph with the highest edge density prefix = ", size_max_ed)


        if plot1 == 1
            P_add = plot(1:n, liste_add, title = "degree density prefix")
            png( P_add , nom_fichier_plot_add )   # afficher, pour chaque individu (chaque noeud), son core en fonction de son degre
            P_ed = plot(1:n, liste_ed, title = "edge density prefix")
            png( P_ed , nom_fichier_plot_ed )   # afficher, pour chaque individu (chaque noeud), son core en fonction de son degre
        end
    end

    println("Fin exercice 1")
    println(" ")
    println(" ")
end



# ------------------------ EXERCICE 2 ------------------------------------------#

if ex2 == 1

    println("Debut exercice 2")
    # meme fonction que pour l exercice 1
    # on utilise ordre_noeud et tri_noeud
    c_max, liste_core, ordre_noeud, tri_noeud = k_core(fichier2, informations_core)

    degres, liste_degres, voisins = adjacency_a(fichier2)
    n = length(liste_degres)


    P2 = plot(liste_degres, liste_core, seriestype = :scatter, title = "Number of core in function of number of degree")
    png( P2 , nom_fichier_plot_core_degre )
 

    # argument : ordre_noeud, tri_noeud
    # return -> liste_anomalous : liste de tous les noeuds anormaux
    liste_anomalous = anomalous_authors(liste_degres, liste_core, ratio)
    println("nombre de noeuds anormaux = ", length(liste_anomalous))

    # return -> liste de tous les noms de personnes anormales
    liste_ID = name_authors("ID.txt", liste_anomalous)
    println("personnes anomarles : ", liste_ID)

    println("Fin exercice 2")
end
=#

######################################################################################################################################

##### TP3
### ex 1
# PageRank basique

# println(multiplication([1 3; 2 1; 2 3; 3 2], [1, 1, -1, 1] , 4, [1, 4, -1], 3) )


# filename = "data/basic.txt"
# filename = "data/basic_vide.txt"
# filename = "data/alr21--dirLinks--enwiki-20071018.txt"
# other_filename = "data/alr21--pageNum2Name--enwiki-20071018.txt"
# categ_filename = "data/alr21--pageCategList--enwiki--20071018.txt"
# categ_other_filename = "data/alr21--categNum2Name--enwiki-20071018.txt"
# a, b, c, d, e, f, g = traitement(filename);
# println(a)
# println(b)
# println(c)
# println(d)
# println(e)
# println(f)
# println(g)

# PageRank(filename, 0.15, 50);

# println("terminé")
# countlines(filename)

# list_ALPHA = [0.1, 0.15, 0.2, 0.5, 0.9]
# courbes(filename, list_ALPHA, 20)

# # TRESTE(other_filename)

# # liste_M, liste_m = fin_exercice_1(filename, other_filename)
# # println(liste_M)
# # println(liste_m)

# # perso_PageRank(filename, 442682, 0.15, 20)

# chess_boxing_ID_cat(categ_other_filename)
# println(length(L_C), " ", length(L_B))
# chess_boxing_memory(categ_filename)

# courbe_ex3(filename, 0.15, 20)

# en ayant cherché à la main les ID de "Chess" et "Boxing", 5134 et 4243
# fin_exercice_3(filename, other_filename, 0.15, 20)
# println(liste)

####################################################################################################

# a, b, c = adjacency_a(filename)
# println(a)
# println(b)
# println(c)

# truc = k_core_decomposition(filename)










####################################################################################################

# # generation("data/test_TP4.txt", 0.6, 0.03)

# # generation("benchmark_TP4_ex3/ex1_1.txt", 400, 0.6, 0.03)
# # generation("benchmark_TP4_ex3/ex1_2.txt", 400, 0.4, 0.04)
# # generation("benchmark_TP4_ex3/ex1_3.txt", 1000, 0.6, 0.03)
# # generation("benchmark_TP4_ex3/ex1_4.txt", 10000, 0.6, 0.03)
# # generation("benchmark_TP4_ex3/ex1_5.txt", 20000, 0.5, 0.025)

# # filename = "data/basic.txt"
# # filename = "data/basic_vide.txt"
# # filename = "data/test_TP4.txt"
# filename = "data/TP4_ex5_test2.txt"
# generation(filename, 400, 0.3, 0.06)

# @time L, Niter = label_propagation(filename)
# println("Niter = $Niter")
# affichage(filename)

# filename = "benchmark_TP4_ex3/ex1_6.txt"
# generation(filename, 400, 0.3, 0.06)
# affichage(filename)

# ----------------------------------------

# filename = "benchmark_TP4_ex3/ex1_1.txt"
# @time affichage(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex1_2.txt"
# @time affichage(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex1_3.txt"
# @time affichage(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex1_4.txt"
# @time affichage(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex1_5.txt"
# @time affichage(filename)
# println("passage au test suivant")

# ----------------------------------------

# filename = "benchmark_TP4_ex3/ex3_1.nse"
# @time affichage_LFR(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex3_2.nse"
# @time affichage_LFR(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex3_3.nse"
# @time affichage_LFR(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex3_4.nse"
# @time affichage_LFR(filename)
# println("passage au test suivant")

# filename = "benchmark_TP4_ex3/ex3_5.nse"
# @time affichage_LFR(filename)
# println("passage au test suivant")


# ----------------------------------------
# clique = ex_5_2("data/TP4_ex5_test2.txt")
# @time clique = ex_5_2("benchmark_TP4_ex3/ex1_1.txt");
# println("fin du test")
# @time clique = ex_5_2("benchmark_TP4_ex3/ex1_3.txt");
# println("fin du test")
### ne termine pas
# @time clique = ex_5_2("benchmark_TP4_ex3/ex1_4.txt");
# println("fin du test")