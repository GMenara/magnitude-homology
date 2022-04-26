import networkx as nx

n=4
G=nx.cycle_graph(n)
G.add_edge(1,3)
G.add_edge(2,4)

#print(['The length of the path',path,'is',len(path), for path in nx.all_shortest_paths(G, source=0, target=2)])

#for counter, path in enumerate(nx.all_shortest_paths(G,source=0,target=2)):
#    print('The length of the path',path,'is',len(path)-1)

#print(counter+1)

shortes_paths_between_two = []
for i in G.nodes:
    for j in G.nodes:
        if j!=i:
            shortest = list(nx.all_shortest_paths(G,i,j))
            print('the s.ps. between',i,'and',j,'are',len(shortest))
            shortes_paths_between_two.append(shortest)
print(shortes_paths_between_two)

