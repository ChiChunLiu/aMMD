import argparse


def output_original_graph(graph, out):
    with open(graph, 'r') as graph, open(out, 'w') as out:
        for line in graph:
            out.write(line)

def list_all_branches(graph):
    branches = list()
    with open(graph, 'r') as graph:
        for line in graph:
                line = line.strip().split()
                if line[0] == 'edge':
                    branches.append(line[1])
    return branches

def reattach_node(graph, nodes, branch, out):
    '''
    graph: graph file
    nodes: n_a, n_b, n_m
    branch: target branch to insert n_m
    out: output file
    '''

    with open(graph, 'r') as graph, open(out, 'w') as out:
        n_a, n_b, n_m = nodes
        for line in graph:
            line = line.strip().split()
            if line[0] == 'edge':
                # attach the node to a new position
                if line[1] == branch:
                    line1, line2 = line.copy(), line.copy()
                    line1[3], line2[2] = n_m, n_m
                    line1[1] = 'b_{}_{}'.format(line1[2], line1[3])
                    line2[1] = 'b_{}_{}'.format(line2[2], line2[3])
                    out.write('\t'.join(line1) + '\n')
                    out.write('\t'.join(line2) + '\n')
                # reconnect the broken branch
                elif line[1] == 'b_{}_{}'.format(n_a, n_m):
                    pass
                elif line[1] == 'b_{}_{}'.format(n_m, n_b):
                    line[2], line[3] = n_a, n_b
                    line[1] = 'b_{}_{}'.format(n_a, n_b)
                    out.write('\t'.join(line) + '\n')
                else:
                    out.write('\t'.join(line) + '\n')
            else:
                out.write('\t'.join(line) + '\n')



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--node_m', type=str, help='a node to reattach to somewhere else')
    parser.add_argument('-a', '--node_a', type=str, help='node a to reconnect with node b')
    parser.add_argument('-b', '--node_b', type=str, help='node b to reconnect with node a')
    parser.add_argument('-g', '--graph', type=str, help='input graph name')
    parser.add_argument('-o', '--output', type=str, help='output graph prefix')
    parser.add_argument('-p', '--branch', type=str, default = '', help='a specific branch to reattach to')
    args = parser.parse_args()

    nodes = [args.node_a, args.node_b, args.node_m]
    branches = list_all_branches(args.graph)
    exclude =  ['b_{}_{}'.format(nodes[0], nodes[2]), 'b_{}_{}'.format(nodes[2], nodes[1])]
    branches = [b for b in branches if b not in exclude]


    if args.branch:
        reattach_node(args.graph, nodes, args.branch, args.output + '.graph')
    else:
        output_original_graph(args.graph, '{}.{}.graph'.format(args.output, '0'))
        for i, b in enumerate(branches, 1):
            reattach_node(args.graph, nodes, b, '{}.{}.graph'.format(args.output, str(i)))
