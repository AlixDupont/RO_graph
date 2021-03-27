import numpy as np
import matplotlib.pyplot as plt
import time

from trucs_python import PR010, PR015, PR020, PR050, PR090, Ind, Outd

from trucs_python2 import vrais_PR, nombre_echecs, permutation

permutation = permutation - 1
# pour passer de Julia à Python

## tests exercice 3
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



## retour exercice 2

# # print(len(PR010))
# # print(len(PR015))
# # print(len(PR020))
# # print(len(PR050))
# # print(len(PR090))
# # print(len(Ind))
# # print(len(Outd))
### ont la bonne taille de 2070486

# # print(min(PR010))
# # print(min(PR015))
# # print(min(PR020))
# # print(min(PR050))
# # print(min(PR090))
# # print(min(Ind))
# # print(min(Outd))
# # print(max(Ind))
# # print(max(Outd))
### les PR ont bien des minima > 0 (~ 10^-8)
### les min des degrés sont 0 normal
### les max des degrés sont 229735.0, 5308.0 mais pas des entiers (? dans la pythonisation)

# log_PR010 = np.log10(PR010)
# log_PR015 = np.log10(PR015)
# log_PR020 = np.log10(PR020)
# log_PR050 = np.log10(PR050)
# log_PR090 = np.log10(PR090)

# n = len(Ind)
# # print(n)
# log_Ind = np.zeros(n)
# log_Outd = np.zeros(n)
# for i in range (n):
#     if Ind[i] == 0:
#         log_Ind[i] = -1
#     else:
#         log_Ind[i] = np.log(Ind[i])

#     if Outd[i] == 0:
#         log_Outd[i] = -1
#     else:
#         log_Outd[i] = np.log(Outd[i])

# print("logarithmisation terminée")

# # # taille = len(vrais_PR)
# # # T = np.array([i for i in range(taille)])



# # # fig, ax = plt.subplots(1, 1, figsize=(4, 4))

# # # ax.plot(np.array([4, 2, 3, 1]), np.array([-1, -2, 0, 1]), '.', label="truc")
# # # fig.suptitle("chose")
# # # plt.show()

# fig, (ax1, ax2, ax3, ax4, ax5, ax6) = plt.subplots(nrows=6, ncols=1, figsize=(8, 12))

# ax1.plot(PR015, Ind, '.', markersize='2', label="degré entrant")
# # ax1.set_xscale('log')
# ax1.set_yscale('log')
# ax1.legend(loc='upper center')

# ax2.plot(PR015, Outd, '.', markersize='2', label="degré sortant")
# # ax2.set_xscale('log')
# ax2.set_yscale('log')
# ax2.legend(loc='upper center')

# ax3.plot(PR015, PR010, '.', markersize='2', label="PageRank de 0.10")
# # ax3.set_xscale('log')
# # ax3.set_yscale('log')
# ax3.legend(loc='upper center')

# ax4.plot(PR015, PR020, '.', markersize='2', label="PageRank de 0.20")
# # ax4.set_xscale('log')
# # ax4.set_yscale('log')
# ax4.legend(loc='lower center')

# ax5.plot(PR015, PR050, '.', markersize='2', label="PageRank de 0.50")
# # ax5.set_xscale('log')
# # ax5.set_yscale('log')
# ax5.legend(loc='lower center')

# ax6.plot(PR015, PR090, '.', markersize='2', label="PageRank de 0.90")
# # ax6.set_xscale('log')
# # ax6.set_yscale('log')
# ax6.legend(loc='lower center')



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

# plt.show()
# time.sleep(10)
# plt.savefig("plots_ex_2_normalvalues.png", bbox_inches='tight')


# --------------------------------------------------
### figure exercice 3 : bonne allure mais pas les bonnes valeurs

# fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1, figsize=(8, 8))

# ax1.plot(T, vrais_PR, label="PageRank")
# ax1.set_xscale('log')
# ax1.set_yscale('log')
# ax1.legend(loc='lower left')
# ax1.set_ylim(0.0000001, 1)
# ax2.plot(T, nombre_echecs, label="# pages d'échecs")
# ax2.legend(loc='upper left')
# ax2.set_xscale('log')

# fig.suptitle("PageRank personnalisé en Magnus Carlsen")
# # plt.show()
# plt.savefig("courbe_ex3.png", bbox_inches='tight')

