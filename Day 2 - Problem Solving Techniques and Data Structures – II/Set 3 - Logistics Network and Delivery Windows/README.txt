SET 3 – LOGISTICS NETWORK AND DELIVERY WINDOWS
================================================

BUSINESS PROBLEM
A courier company needs to organize hub identifiers, detect repeated parcel
scans, find efficient hub routes and analyze delivery volumes.

IMPLEMENTED TASKS
1. Hub-code BST with insert, search and height calculation. The program also
   compares the height after balanced-looking and sorted insertion orders.
2. Hash-based tracking lookup detects repeated scans of the same parcel at
   the same hub. A scan at a different hub is not treated as a duplicate.
3. An adjacency list represents ten hubs. BFS finds the fewest-hop route;
   DFS lists all hubs reachable from the central depot.
4. Fixed-size sliding window finds the four-hour window with the highest
   average parcel count.
5. Two pointers check a route description as a palindrome after removing
   separators and ignoring letter case.

RUN
    python logistics_network.py

FILES
- logistics_network.py: complete source code
- execution_output.txt: sample execution output
- algorithm_explanations.md: algorithm choices, complexity and graph details

GRAPH ASSUMPTION
The sample network is undirected: each direct connection is listed in both
hubs' adjacency lists. BFS minimizes the number of edges (hops), not physical
distance or travel time.
