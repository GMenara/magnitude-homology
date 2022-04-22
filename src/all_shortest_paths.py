# Python program that returns all the shortest paths between two given vertices.
# Main idea:  do a Breadth First Traversal (BFS) for a graph (https://en.wikipedia.org/wiki/Breadth-first_search):
# 1. start BFS traversal from source vertex;
# 2. while doing BFS, store the shortest distance to each of the other nodes and also maintain a parent vector for each of the nodes;
# 3. make the parent of source node as “-1” (for each node, it will store all the parents for which it has the shortest distance from the source node);
# 4. recover all the paths using parent array (at any instant, we will push one vertex in the path array and then call for all its parents);
# 5. if we encounter “-1” in the above steps, then it means a path has been found and can be stored in the paths array.

from src import boundary_matrix, create_graph
import networkx as nx
from typing import List
from sys import maxsize
from collections import deque

# Function to form edge between two vertices src and dest
def add_edge(adj: List[List[int]],
             src: int, dest: int) -> None:
    adj[src].append(dest)
    adj[dest].append(src)


# Function which finds all the paths and stores it in paths array
def find_paths(paths: List[List[int]], path: List[int],
               parent: List[List[int]], n: int, u: int) -> None:
    # Base Case
    if (u == -1):
        paths.append(path.copy())
        return

    # Loop for all the parents of the given vertex
    for par in parent[u]:
        # Insert the current vertex in path
        path.append(u)

        # Recursive call for its parent
        find_paths(paths, path, parent, n, par)

        # Remove the current vertex
        path.pop()


# Function which performs bfs from the given source vertex
def bfs(adj: List[List[int]],
        parent: List[List[int]], n: int,
        start: int) -> None:
    # dist will contain the shortest distance from start to every other vertex
    dist = [maxsize for _ in range(n)]
    q = deque()

    # Insert source vertex in queue and make its parent -1 and distance 0
    q.append(start)
    parent[start] = [-1]
    dist[start] = 0

    # Until Queue is empty
    while q:
        u = q[0]
        q.popleft()
        for v in adj[u]:
            if (dist[v] > dist[u] + 1):

                # A shorter distance is found
                # So erase all the previous parents and insert new parent u in parent[v]
                dist[v] = dist[u] + 1
                q.append(v)
                parent[v].clear()
                parent[v].append(u)

            elif (dist[v] == dist[u] + 1):

                # Another candidate parent for the shortest path found
                parent[v].append(u)


# Function which prints all the paths from start to end
def print_paths(adj: List[List[int]], n: int,
                start: int, end: int) -> None:
    paths = []
    path = []
    parent = [[] for _ in range(n)]

    # Function call to bfs
    bfs(adj, parent, n, start)

    # Function call to find_paths
    find_paths(paths, path, parent, n, end)
    for v in paths:

        # Since paths contain each path in reverse order, so reverse it
        v = reversed(v)

        # Print node for the current path
        #for u in v:
            #print(u, end=" ")
        #print()
    return len(paths)

#
#
# Check if it works ---> YEP
#
#n=4
#G=nx.cycle_graph(n)
#G.add_edge(1,3)
#create_graph.graph(G)

#adj = [[] for _ in range(n)]

#for e in G.edges:
#    list(e)
#    add_edge(adj, e[0], e[-1])

#src = 0
#dest = 2
#print_paths(adj, n, src, dest)