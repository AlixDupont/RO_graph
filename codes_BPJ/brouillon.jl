function traitement(fichier)
    f = open(fichier)
    compteur_noeuds = 0
    compteur_aretes = countlines(fichier) - 2
    Tind = zeros(Int, 0, 2)
    Tv = zeros(0, 1)
    T_local_ind = zeros(Int, 0, 2)
    T_local_v = zeros(0, 1)
    memory_N1 = -1
    compteur_local = 0

    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        compteur_aretes += 1
        N1, N2 = conversion(ln)
        compteur_noeuds = max(compteur_noeuds, N1, N2)
        if N1 != memory_N1 # nouveau noeud avec ses successeurs
            memory_N1 = N1
            T_local_v /= compteur_local # diviser par le degré, pour les noeuds ayant des successeurs
            Tv = [Tv; T_local_v]
            Tind = [Tind; T_local_ind]
            
            compteur_local = 1
            T_local_ind = [N1 N2]
            T_local_v = [1.0]
        else
            compteur_local += 1
            T_local_ind = [T_local_ind; [N1 N2]]
            T_local_v = [T_local_v ; 1.0]
        end

    end
    # une dernière fois pour la dernière valeur de N1
    Tv = [Tv; T_local_v / compteur_local]
    Tind = [Tind; T_local_ind]

    return compteur_noeuds, compteur_aretes, Tind, Tv
end

##### version avec les noeuds inexistants
function traitement(fichier)
    f = open(fichier)
    compteur_noeuds = 0
    compteur_aretes = countlines(fichier) - 2
    println("countlines terminé")
    # Tind = zeros(Int, 0, 2)
    # Tv = zeros(0, 1)
    # T_local_ind = zeros(Int, 0, 2)
    # T_local_v = zeros(0, 1)
    Tind = zeros(Int, compteur_aretes, 2)
    Tv = ones(compteur_aretes, 1)
    
    memory_N1 = -1
    compteur_local = 0
    compteur_aretes = 0

    for ln in eachline(fichier)
        if ln[1] == '#'
            continue
        end
        # if mod(compteur_aretes, 10000) == 0
        #     println(compteur_aretes)
        # end
        compteur_aretes += 1
        N1, N2 = conversion(ln)
        compteur_noeuds = max(compteur_noeuds, N1, N2)
        Tind[compteur_aretes, :] = [N1; N2]

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

    return compteur_noeuds, compteur_aretes, Tind, Tv
end


function PageRank(fichier, alpha, t)

    n, m, Tind, Tv = traitement(fichier)
    println("traitement terminé")
    P = ones(n)/n
    
    for time in 1:t
        P = multiplication(Tind, Tv, m, P, n) # fait la multiplication entre une liste de coordonnées et un vecteur
        P = (1 - alpha) * P .+ 1/n
        P .+= (1 - sum(P))/n
        println("itération $time")
    end
    println(maximum(P))
    println(minimum(P))
    println(std(P))
    return P
end
