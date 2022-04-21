#code by Jerome Roehm

import numpy as np
import networkx as nx
import matplotlib.pyplot as plt

color_list=['#e6194B', '#3cb44b','#4363d8', '#ffe119', '#f58231', '#911eb4', '#42d4f4', '#f032e6',
            '#bfef45', '#fabebe', '#469990', '#e6beff', '#9A6324', '#fffac8', '#800000', '#aaffc3',
            '#808000', '#ffd8b1', '#e60075', '#a9a9a9']

def graph(data, node_labels=False, weighted=False, normalize=False,
          layout=True, save=False, figsize=(6, 6), colors=False, font_size=14):
    if weighted == False:
        if type(data) == type(3 * np.ones((2, 2))) or type(data) == type(nx.to_numpy_matrix(nx.path_graph(3))):
            G = nx.from_numpy_matrix(data)
            if node_labels != False:
                mapping = {}
                for i in range(len(node_labels)):
                    mapping[i] = node_labels[i]
                nx.relabel_nodes(G, mapping=mapping, copy=False)
        elif type(data) == type(nx.complete_graph(3)):
            G = data
        plt.figure(figsize=figsize)
        if layout == True or layout == 'spring':
            pos = nx.spring_layout(G)
        elif layout == 'circular':
            pos = nx.circular_layout(G)

        if colors != False:
            node_color = []
            for node in G.nodes():
                node_color.append(color_list[node % 20])
            nx.draw_networkx_nodes(G, pos=pos, node_color=node_color, node_size=300, alpha=0.5, edgecolors='k',
                                   linewidths=0.2)
        else:
            nx.draw_networkx_nodes(G, pos=pos, node_color='w', node_size=300, edgecolors='k', linewidths=0.2)
        nx.draw_networkx_edges(G, pos=pos)
        nx.draw_networkx_labels(G, pos, font_size=font_size)
        plt.axis('off')
        plt.axis('equal')
        # plt.savefig("ex_graph.png", dpi=300)
        if save != False:
            plt.savefig(save)
        plt.show()

    elif weighted:
        if type(data) == type(3 * np.ones((2, 2))):
            G = nx.from_numpy_matrix(data)
            if node_labels != False:
                mapping = {}
                for i in range(len(node_labels)):
                    mapping[i] = node_labels[i]
                nx.relabel_nodes(G, mapping=mapping, copy=False)
        elif type(data) == type(nx.complete_graph(3)):
            G = data

        plt.figure(figsize=figsize)
        if layout == True or layout == 'spring':
            pos = nx.spring_layout(G)
        elif layout == 'circular':
            pos = nx.circular_layout(G)
        if colors != False:
            node_color = []
            for node in G.nodes():
                node_color.append(color_list[node % 20])
            nx.draw_networkx_nodes(G, pos=pos, node_color=node_color, node_size=300, alpha=1, edgecolors='k',
                                   linewidths=0.2)
        else:
            nx.draw_networkx_nodes(G, pos=pos, node_color='w', node_size=300, edgecolors='k', linewidths=0.2)

        # if graph is unweighted, assign unit weights
        if nx.is_weighted(G) == False:
            for edge in G.edges():
                G[edge[0]][edge[1]]['weight'] = 1.0

        edges, weights = zip(*nx.get_edge_attributes(G, 'weight').items())
        weights = np.array(weights)
        if normalize:
            if max(abs(weights)) != 0:
                weights = weights / max(abs(weights))
        n = nx.draw_networkx_edges(G, pos=pos, edge_cmap=plt.cm.viridis, edge_color=weights, width=3.0)
        nx.draw_networkx_labels(G, pos, font_size=14)
        plt.axis('off')
        plt.axis('equal')
        plt.colorbar(n)
        if save != False:
            plt.savefig(save)
        plt.show()