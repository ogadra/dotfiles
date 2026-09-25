{
  # Exec() rules only match the leading words of a command, so commands hidden in pipes or chains are left to the pre-bash hook
  allow = [
    "Exec(git push origin)"
  ];
  deny = [
    "Exec(sudo)"
    "Exec(xargs rm)"
    "Exec(git commit -a)"
    "Exec(git add .)"
    "Exec(git add -u)"
    "Exec(git add -A)"
  ];
}
