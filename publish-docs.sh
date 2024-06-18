#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

mkdocs build
mv site ../playground-one-pages/
rm -rf ../playground-one-pages/docs
mv ../playground-one-pages/site ../playground-one-pages/docs
cd ../playground-one-pages/
git status

echo
echo "${bold}Do you want to commit and push?${normal}"
echo "  Only 'yes' will be accepted to approve."
echo
read -p "${bold}Enter a value: ${normal}" TEMP

if [[ "${TEMP}" == "yes" ]]; then
  git add .
  git commit . -m "update"
  git push
else
  echo
  echo "${bold}Error:${normal} error asking for approval: interrupted"
fi
