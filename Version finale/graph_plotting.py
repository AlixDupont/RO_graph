import community as community_louvain
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import time
import resource

# import igraph as ig


# G = nx.Graph()


def conversion(chaine):
    i = 0
    while chaine[i] == "0" or chaine[i] == "1" or chaine[i] == "2" or chaine[i] == "3" or chaine[i] == "4" or chaine[i] == "5" or chaine[i] == "6" or chaine[i] == "7" or chaine[i] == "8" or chaine[i] == "9":
        i += 1
    return int(chaine[0:i]), int(chaine[i+1:-1])

"""
transforme la ligne particulière en tableau
"""
def conversion2(chaine):
    l = len(chaine)
    i = 0
    iautre = 0
    liste = []
    while i < l-1:
        ci = chaine[i]
        while i < l-1 and ci != "1" and ci != "2" and ci != "3" and ci != "4" and ci != "5" and ci != "6" and ci != "7" and ci != "8" and ci != "9" and ci != "0":
            i += 1
            ci = chaine[i]
        iautre = i
        while i < l-1 and ci != "\'":
            i += 1
            ci = chaine[i]
        if i >= l-2:
            break
        liste.append(int(chaine[iautre:i]))
    return liste



# f = open("data/test_TP4.txt", "r")
# for i in range(400):
#     G.add_node(i+1)

# for line in f.readlines():
#     if line[0] == "[":
#         Couleurs_indices = conversion2(line)
#     elif len(line) == 1:
#         continue
#     else:
#         a, b = conversion(line)
#         G.add_edge(a, b)


# print(Couleurs_indices)

# liste_couleurs_python = np.array(["green", "deepskyblue", "magenta", "blue", "lime", "slategrey", "red", "orange", "yellow"])

# Couleurs_indices = np.array(Couleurs_indices)
# colors = liste_couleurs_python[Couleurs_indices]

# colors = ['deepskyblue'] * 400

# nx.drawing.nx_pylab.draw_networkx(G, with_labels=False, node_size=25, node_color=colors, alpha=0.8, edge_color=(0.75, 0.75, 0.75))
# plt.show()
# plt.savefig("graphe_ex2.png")

# ----------------------------------------

# filename = "data/basic.txt"
filename = "data/test_TP4.txt"

def counting(fichier):
    f = open(fichier)
    cn = 0
    ca = 0
    for line in f.readlines():
        if len(line) == 0 or len(line) == 1 or line[0] == "#" or line[0] == "[":
            continue
        else:
            u, v = conversion(line)
            if max(u, v) > cn:
                cn = max(u, v)
            ca += 1
    f.close()
    return cn, ca

def adj_m(fichier):
    cn, ca = counting(fichier)
    M = np.zeros((cn, cn))
    f = open(fichier)
    lastline = []
    for line in f.readlines():
        if len(line) == 0 or len(line) == 1 or line[0] == "#":
            continue
        elif line[0] == "[":
            lastline = line
        else:
            u, v = conversion(line)
            M[u-1, v-1] = 1
            M[v-1, u-1] = 1
    return M, lastline


"""
conversion de la ligne des labels de la forme "['?', '?', ..., '?']"
"""
def conversion3(chaine):
    liste = []
    N = len(chaine)
    i = 0
    while i < N-1:
        ci = chaine[i]
        while i < N-1 and ci != "0" and ci != "1" and ci != "2" and ci != "3" and ci != "4" and ci != "5" and ci != "6" and ci != "7" and ci != "8" and ci != "9":
            i += 1
            ci = chaine[i]
        iautre = i
        while i < N-1 and ci != "\'":
            i += 1
            ci = chaine[i]
        liste.append(int(chaine[iautre:i]))
        if i >= N-2:
            break
    return np.array(liste) - 1

"""
conversion d'une partition en tableau classique
"""
def conversion4(partition):
    n = len(partition)
    P = np.zeros(n, int)
    for i in range(n):
        P[i] = int(float(partition[i]))
    return P

# # T = conversion3("['1', '1', '12', '1', '1', '1', '1']")
# # print(T)


def commun_louv(fichier):
    M, l = adj_m(fichier)
    G = nx.from_numpy_array(M)
    partition = community_louvain.best_partition(G)

    return conversion4(partition), conversion3(l)

# P_louvain, labels = commun_louv(filename)

# print(P_louvain)
# print(labels)



def conversion_LFR(chaine):
    n = len(chaine)
    i = 0
    while i < n-1:
        ci = chaine[i]
        while i < n-1 and (ci == "0" or ci == "1" or ci == "2" or ci == "3" or ci == "4" or ci == "5" or ci == "6" or ci == "7" or ci == "8" or ci == "9"):
            i += 1
            ci = chaine[i]
        i1 = int(chaine[0:i])
        while i < n-1 and ci != "0" and ci != "1" and ci != "2" and ci != "3" and ci != "4" and ci != "5" and ci != "6" and ci != "7" and ci != "8" and ci != "9":
            i += 1
            ci = chaine[i]
        I = i
        while i < n-1 and (ci == "0" or ci == "1" or ci == "2" or ci == "3" or ci == "4" or ci == "5" or ci == "6" or ci == "7" or ci == "8" or ci == "9"):
            i += 1
            ci = chaine[i]
        i2 = int(chaine[I:i])
        return i1, i2

def counting_LFR(fichier):
    f = open(fichier)
    cn = 0
    ca = 0
    for line in f.readlines():
        if len(line) == 0 or len(line) == 1 or line[0] == "#" or line[0] == "[":
            continue
        else:
            u, v = conversion_LFR(line)
            if max(u, v) > cn:
                cn = max(u, v)
            ca += 1
    f.close()
    return cn, ca

def adj_m_LFR(fichier):
    cn, ca = counting_LFR(fichier)
    M = np.zeros((cn, cn))
    f = open(fichier)
    lastline = []
    for line in f.readlines():
        if len(line) == 0 or len(line) == 1 or line[0] == "#":
            continue
        elif line[0] == "[":
            lastline = line
        else:
            u, v = conversion_LFR(line)
            M[u-1, v-1] = 1
            M[v-1, u-1] = 1
    return M, lastline

def commun_louv_LFR(fichier):
    M, l = adj_m_LFR(fichier)
    G = nx.from_numpy_array(M)
    partition = community_louvain.best_partition(G)

    return conversion4(partition), conversion3(l)



def traitement_LFR(tableau, n):
    things = [[] for i in range(n)] # n est très très par rapport au nomrbe de communautés
    
    for i in range(n):
        things[tableau[i]-1].append(i)
    return things

def traitement_sol_LFR(fichier):
    f = open(fichier)
    array = np.zeros(len(f.readlines()), int)
    f.close()
    f = open(fichier)
    i = 0
    for line in f.readlines():
        i1, i2 = conversion(line)
        array[i] = i2
        i += 1
    f.close()
    return array


def traitement_into_adj_a(liste, n, liste2):
    voisins = [[] for i in range(n)]
    for i in range(n):
        voisins[i] = liste[liste2[i]-1]
    return voisins


def hand_intersection(L1, L2):
    compteur = 0
    l1 = len(L1)
    l2 = len(L2)
    if min(l1, l2) == 0:
        return 0

    min1 = L1[0]
    min2 = L2[0]
    I1 = 0
    I2 = 0
    while I1 + I2 <= l1 + l2 - 2:
        if min2 == min1:
            compteur += 1
            I1 = I1+1
            I2 = I2+1
            min1 = L1[min(l1-1, I1)]
            min2 = L2[min(l2-1, I2)]
        elif I2 == l2-1 and min2 < min1: # terminé pour L2
            break
        elif I1 == l1-1 and min1 < min2: # terminé pour L1
            break
        elif I2 < l2-1 and min2 < min1:
            while min2 < min1 and I2 < l2-1:
                I2 += 1
                min2 = L2[I2]
            
        elif min1 < min2 and I1 < l1-1:
            while min1 < min2 and I1 < l1-1:
                I1 += 1
                min1 = L1[I1]

        else: # cas terminal, 
            break
    return compteur

def comparaison_LFR(fichier, autre_fichier):
    P, l = commun_louv_LFR(fichier)
    print(P)
    print(l)
    n = len(P)
    S = traitement_sol_LFR(autre_fichier)
    print(S)
    groupedP = traitement_LFR(P, n)
    groupedl = traitement_LFR(l, n)
    groupedS = traitement_LFR(S, n)

    adjacence_P = traitement_into_adj_a(groupedP, n, P)
    adjacence_l = traitement_into_adj_a(groupedl, n, l)
    adjacence_S = traitement_into_adj_a(groupedS, n, S)

    compteur_P = 0
    compteur_l = 0

    for i in range(n):
        len_P = len(adjacence_P[i])
        len_l = len(adjacence_l[i])
        len_S = len(adjacence_S[i])

        compteur_P += len_P + len_S - 2 * hand_intersection(adjacence_P[i], adjacence_S[i])
        compteur_l += len_l + len_S - 2 * hand_intersection(adjacence_l[i], adjacence_S[i])
    return compteur_P, compteur_l


# print(comparaison_LFR("benchmark_TP4_ex3/ex3_5.nse", "benchmark_TP4_ex3/ex3_5.nmc"))

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex1_1.txt"
# P, l = commun_louv(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex1_2.txt"
# P, l = commun_louv(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex1_3.txt"
# P, l = commun_louv(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex1_4.txt"
# P, l = commun_louv(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex1_5.txt"
# P, l = commun_louv(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex1_6.txt"
# P, l = commun_louv(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# ----------------------------------------
# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex3_1.nse"
# P, l = commun_louv_LFR(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex3_2.nse"
# P, l = commun_louv_LFR(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex3_3.nse"
# P, l = commun_louv_LFR(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex3_4.nse"
# P, l = commun_louv_LFR(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")

# time_start = time.perf_counter()
# filename = "benchmark_TP4_ex3/ex3_5.nse"
# P, l = commun_louv_LFR(filename)
# time_elapsed = time.perf_counter() - time_start
# print(time_elapsed)
# print("%5.1f MByte" % (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024 / 1024))
# print("passage au test suivant")