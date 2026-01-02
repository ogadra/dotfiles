{
  allow = [
    "Bash(git push origin:*)"
    "Bash(git push -u origin:*)"
  ];
  deny = [
    "Bash(sudo :*)"
    "Bash(rm -rf:*)"
    "Bash(rm -fr:*)"
    "Bash(rm -r:*)"
    "Bash(rm -f:*)"
    "Bash(rm -R:*)"
    "Bash(rm --recursive:*)"
    "Bash(rm --force:*)"
    "Bash(find :* -delete:*)"
    "Bash(xargs rm:*)"
    "Bash(rmdir:*)"
    "Bash(git push)"
    "Bash(git push origin main)"
    "Bash(git push origin master)"
    "Bash(git push origin production)"
    "Bash(git commit --no-verify:*)"
    "Bash(git commit -a --no-verify:*)"
    "Bash(git commit -am --no-verify:*)"
    "Bash(git commit -a:*)"
    "Bash(git add .)"
    "Bash(git add -u)"
  ];
}
