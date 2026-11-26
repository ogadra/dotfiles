{ pkgs }:
pkgs.writers.writePython3 "block-pr-body" {
  libraries = ps: [
    ps.graphql-core
    ps.tree-sitter
    ps.tree-sitter-bash
  ];
  doCheck = false;
} (builtins.readFile ./block_pr_body.py)
