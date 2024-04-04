#!/bin/bash
mkdocs build
mv site ../playground-one-pages/
rm -rf ../playground-one-pages/docs
mv ../playground-one-pages/site ../playground-one-pages/docs
cd ../playground-one-pages/
git status

echo
echo "Do you want to commit and push?"
echo "  Only 'yes' will be accepted to approve."
echo
read -p "Enter a value: " TEMP

if [[ "${TEMP}" == "yes" ]]; then
  git add .
  git commit . -m "update"
  git push
fi
