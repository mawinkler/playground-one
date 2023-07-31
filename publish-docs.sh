#!/bin/bash
mkdocs build
mv site ../playground-one-pages/
rm -rf ../playground-one-pages/docs
mv ../playground-one-pages/site ../playground-one-pages/docs
