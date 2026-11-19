SET 2 – INSURANCE CLAIMS PROCESSING
===================================

BUSINESS PROBLEM
An insurer needs to organize claims, identify repeated submissions, route
claims through approval stages, monitor spikes and combine regional records.

IMPLEMENTED TASKS
1. Claim ID BST with insert, search and inorder/preorder/postorder traversals.
2. Duplicate detection using a normalized policy number + incident date key.
   Case and whitespace differences are ignored. Python set hashing is used.
3. Directed approval-stage graph; BFS finds a shortest path and DFS detects
   directed cycles.
4. A linear scan identifies the longest consecutive run of days with more
   than 100 claims.
5. Two-pointer merge combines two already-sorted regional claim lists.

RUN
    python insurance_claims.py
    python test_cases.py

TEST COVERAGE
test_cases.py checks empty BSTs, missing searches, duplicate normalization,
empty duplicate input, graph paths, unreachable destinations, empty sliding
window input, threshold behavior, and merging empty or duplicate-containing
sorted lists.

FILES
- insurance_claims.py: complete algorithms and sample demonstration
- test_cases.py: standard-library unit tests
