(require :vis)

(fn check-line [line]
  (if (line:match "^ *$") false
      (line:find "^ *#") false
      (line:find "^ *%*") false
      (line:find "^ *%&") false
      true))

(fn get-indent [line]
  (var indent (line:find "[^ ]"))
  (var is-seq false)
  (when (line:find "^ *%- ")
    (set is-seq true)
    (set indent (+ indent 2)))
  (values indent is-seq))

(fn get-yaml-key [line]
  (var key (line:match "^ *-? *([^ ]+):"))
  (if (not key)
      false
      (do
        (when (key:find "." 1 true)
          (set key (string.format "\"%s\"" key)))
        key)))

(vis:map vis.modes.NORMAL :<C-p>
  (fn [keys]
    (var line-num vis.win.selection.line)
    (var curr-line
         (. vis.win.file.lines line-num))
    (var yaml-path "")
    (when (check-line curr-line)
      (var (curr-indent is-seq)
           (get-indent curr-line))
      (var trigger-indent curr-indent)
      (var yaml-key
           (get-yaml-key curr-line))
      (when yaml-key
        (set yaml-path yaml-key)
        (while (> curr-indent 1)
          (set line-num (- line-num 1))
          (when (> line-num 0)
            (set curr-line
                 (. vis.win.file.lines line-num))
            (when curr-line
              (when (check-line curr-line)
                (var seq-indicator "")
                (when is-seq
                  (set seq-indicator "[]"))
                (set (curr-indent is-seq)
                     (get-indent curr-line))
                (when (< curr-indent
                         trigger-indent)
                  (set trigger-indent
                       curr-indent)
                  (set yaml-key
                       (get-yaml-key curr-line))
                  (when yaml-key
                    (set yaml-path
                         (string.format "%s%s.%s"
                                        yaml-key
                                        seq-indicator
                                        yaml-path))))))))))
    (vis:info yaml-path)
    yaml-path)
    "yaml path")
