import system except getCommand, setCommand, switch, `--`,
  packageName, version, author, description, license, srcDir, binDir, backend,
  skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, bin, foreignDeps,
  requires, task, packageName
import nimscriptapi, strutils
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
  echo "remove old build"
  exec "git checkout gh-pages"
  rmDir "docs"

  echo "build docs"
  exec "git checkout master"
  mkDir "docs"
  selfExec "doc -o:docs/index.html src/delight.nim"

  echo "commit to gh-pages"
  exec "git checkout gh-pages"
  exec "git add ."
  exec "git commit -m'Updated documentation'"
  exec "git push origin gh-pages"
  exec "git checkout master"

  echo "done"

onExit()
