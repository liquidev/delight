# Package

version       = "0.1.0"
author        = "liquid600pgm"
description   = "Engine-agnostic library for computing 2D raycasted lights"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.0.4"
requires "glm >= 1.1.1"

# Tasks

task buildDoc, "Build documentation onto gh-pages branch":
<<<<<<< Updated upstream
=======
  echo "stash existing changes"
  exec "git add ."
  exec "git stash"

>>>>>>> Stashed changes
  echo "remove old build"
  exec "git checkout gh-pages"
  rmDir "docs"

  echo "build docs"
  exec "git checkout master"
<<<<<<< Updated upstream
  mkDir "docs"
  selfExec "doc -o:docs/index.html src/delight.nim"

  echo "commit to gh-pages"
  exec "git checkout gh-pages"
=======
  mkDir "docs_tmp"
  selfExec "doc -o:docs_tmp/index.html src/delight.nim"

  echo "commit to gh-pages"
  exec "git checkout gh-pages"
  exec "git rm -r docs"
  exec "mv docs_tmp docs"
>>>>>>> Stashed changes
  exec "git add ."
  exec "git commit -m'Updated documentation'"
  exec "git push origin gh-pages"
  exec "git checkout master"

<<<<<<< Updated upstream
=======
  echo "pop stash"
  exec "git stash pop"
>>>>>>> Stashed changes
  echo "done"
