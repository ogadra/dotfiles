{
  allow = [
    "Bash(git push origin:*)"
    "Bash(git push -u origin:*)"
  ];
  deny = [
    "Bash(sudo :*)"
    "Bash(find :* -delete:*)"
    "Bash(xargs rm:*)"
    "Bash(git commit -a:*)"
    "Bash(git add .)"
    "Bash(git add -u)"
    "Bash(git add -A)"
  ];
}
