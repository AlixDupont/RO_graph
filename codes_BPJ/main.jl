using Random
using Plots


### lien github https://github.com/maxdan94/LoadGraph

include("TP1.jl")

include("TP3.jl")

## première application

# filename = "data/basic.txt"
# filename = "data/basic0.txt"
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



####################################################################################################

##### TP3
### ex 1
# PageRank basique

# println(multiplication([1 3; 2 1; 2 3; 3 2], [1, 1, -1, 1] , 4, [1, 4, -1], 3) )


# filename = "data/basic.txt"
# filename = "data/basic_vide.txt"
filename = "data/alr21--dirLinks--enwiki-20071018.txt"
other_filename = "data/alr21--pageNum2Name--enwiki-20071018.txt"
categ_filename = "data/alr21--pageCategList--enwiki--20071018.txt"
categ_other_filename = "data/alr21--categNum2Name--enwiki-20071018.txt"
# a, b, c, d, e = traitement(filename);
# println(a)
# println(b)
# println(c)
# println(d)
# println(e)

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

courbe_ex3(filename, 0.15, 20)