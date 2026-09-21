{
  # Permission mode at session start (default/acceptEdits/plan/bypassPermissions/auto); auto lets the classifier approve tool calls while the deny rules below still win.
  defaultMode = "auto";
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
