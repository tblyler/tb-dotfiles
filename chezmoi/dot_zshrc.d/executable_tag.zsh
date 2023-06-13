if command -v tag &> /dev/null; then
  if command -v ag &> /dev/null; then
    tag() { export TAG_SEARCH_PROG=ag; command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
    alias ag=tag
  fi

  if command -v rg &> /dev/null; then
    trg() { export TAG_SEARCH_PROG=rg; command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
    alias rg=trg
  fi
fi
