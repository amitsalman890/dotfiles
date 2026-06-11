#!/bin/bash
_ssc() {
  local pattern="$1"
  local hosts=($(grep -E '^\s*Host\s+' ~/.ssh/config | awk '{print $2}' | sort -u))

  if [[ -z "$pattern" ]]; then
    echo "Available: ${hosts[*]}"
    return
  fi

  local matches=($(printf '%s\n' "${hosts[@]}" | grep -i "$pattern"))

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No match. Available: ${hosts[*]}"
  elif [[ ${#matches[@]} -eq 1 ]]; then
    ssh "${matches[0]}"
  else
    for i in "${!matches[@]}"; do
      echo "[$((i + 1))] ${matches[$i]}"
    done
    read "c?Pick: "
    ssh "${matches[$((c - 1))]}"
  fi
}
_ssc "$@"
