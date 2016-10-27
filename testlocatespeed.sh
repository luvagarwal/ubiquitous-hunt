out=$(locate -r "/$1*")
read -a paths <<< $out
for path in ${paths[@]}; do
  if [[ $path =~ [^\.]*/$1[^\/]*$ ]]; then
    echo $path
  fi
done
