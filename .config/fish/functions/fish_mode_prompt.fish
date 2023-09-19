function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color --bold blue
      echo 'NORMAL '
    case insert
      set_color --bold brgreen
      echo 'INSERT '
    case replace_one
      set_color --bold yellow
      echo 'REPLCE '
    case visual
      set_color --bold brmagenta
      echo 'VISUAL '
    case '*'
      set_color --bold red
      echo '? '
  end
  set_color normal
end
