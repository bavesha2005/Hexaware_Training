SET 1 – E-COMMERCE CATALOGUE AND TRAFFIC ANALYSIS
=================================================

BUSINESS PROBLEM
An e-commerce platform needs efficient category browsing, SKU look-ups,
microservice deployment planning and peak-traffic analysis.

IMPLEMENTED TASKS
1. Binary Search Tree: inserts 15 categories, searches categories and prints
   inorder, preorder and postorder traversals.
2. Hashing: custom hash table with separate chaining demonstrates a collision.
   The same 100,000 SKUs are stored in a Python dictionary and both structures
   are benchmarked over 10,000 successful look-ups.
3. Graph: Kahn's BFS-based topological sort returns a deployment order.
   DFS detects a circular dependency.
4. Sliding window: identifies the busiest consecutive three-hour period.
5. Two pointers: finds pairs in a sorted list that equal the gift-card value.

RUN
    python ecommerce_catalogue.py

FILES
- ecommerce_catalogue.py: complete source code
- execution_output.txt: sample execution output
- decision_table.md: algorithm and data-structure rationale

NOTES
Benchmark timings depend on hardware and system load. The custom hash table
uses separate chaining, so colliding keys are stored in the same bucket.
