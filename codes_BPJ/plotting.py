import numpy as np
import matplotlib.pyplot as plt

from trucs_python import PR010, PR015, PR020, PR050, PR090, Ind, Outd

from trucs_python2 import vrais_PR, nombre_echecs, permutation

permutation = permutation - 1
# pour passer de Julia à Python

# print(max(vrais_PR))
# print(vrais_PR[0]) egaux car tri décroissant, à 0.15
taille = len(vrais_PR)
T = np.array([i for i in range(taille)])

# print(len(vrais_PR))
# print(len(nombre_echecs))

# print(min(vrais_PR))

# # truc = np.array([1, 2, 3, 4, 5, 6, 7])
# # permutation = np.array([5, 7, 2, 4, 3, 6, 1]) - 1
# # print(truc[permutation])

# # n = len(Ind)
# # print(n)
# # log_Ind = np.zeros(n)
# # log_Outd = np.zeros(n)
# # for i in range (n):
# #     if Ind[i] == 0:
# #         log_Ind[i] = -1
# #     else:
# #         log_Ind[i] = np.log(Ind[i])

# #     if Outd[i] == 0:
# #         log_Outd[i] = -1
# #     else:
# #         log_Outd[i] = np.log(Outd[i])



# en assumant que les PR sont mis en "logarithme", avec l'affichage tel que les points à 0 ont en fait un PR de 0 car non défini
# # print("logarithmisation terminée")

# plt.plot(PR015, log_Ind)
# plt.title("Logarithme du degré entrant par rapport au PageRank 0.15 (*)")
# name_fig = "plot_1.png"
# plt.savefig(name_fig, bbox_inches='tight')

## plt.plot(PR015, log_Outd)
## plt.title("Logarithme du degré sortant par rapport au PageRank 0.15 (*)")
## name_fig = "plot_2.png"
## plt.savefig(name_fig, bbox_inches='tight')
## 
## plt.plot(PR015, PR010)
## plt.title("PageRank 0.10 par rapport au PageRank 0.15 (*)")
## name_fig = "plot_3.png"
## plt.savefig(name_fig, bbox_inches='tight')
## 
## plt.plot(PR015, PR020)
## plt.title("PageRank 0.20 par rapport au PageRank 0.15 (*)")
## name_fig = "plot_4.png"
## plt.savefig(name_fig, bbox_inches='tight')
## 
## plt.plot(PR015, PR050)
## plt.title("PageRank 0.50 par rapport au PageRank 0.15 (*)")
## name_fig = "plot_5.png"
## plt.savefig(name_fig, bbox_inches='tight')
## 
## plt.plot(PR015, PR090)
## plt.title("PageRank 0.90 par rapport au PageRank 0.15 (*)")
## name_fig = "plot_6.png"
## plt.savefig(name_fig, bbox_inches='tight')



# --------------------------------------------------

fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1, figsize=(8, 8))

ax1.plot(T, vrais_PR, label="PageRank")
ax1.set_xscale('log')
ax1.set_yscale('log')
ax2.plot(T, nombre_echecs, label="# pages d'échecs")
ax2.set_xscale('log')

plt.show()

