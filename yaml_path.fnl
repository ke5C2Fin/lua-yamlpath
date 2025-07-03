(require :vis)

(fn check-line [line]
  (not (or (line:match "^ *$")
           (line:find "^ *#")
           (line:find "^ *%*")
           (line:find "^ *%&"))))

(fn get-indent [line]
  (let [indent (line:find "[^ ]")
        is-seq (line:find "^ *%- ")]
    (let [real_indent (if is-seq
                        (+ indent 2)
                        indent)]
      (values indent is-seq))))

(fn get-yaml-key [line]
  (let [key (line:match "^ *-? *([^ ]+):")]
    (if key
      (if (key:find "." 1 true)
        (string.format "\"%s\"" key)
        key)
      false)))

(vis:map vis.modes.NORMAL :<C-p>
  (fn [keys]
    (var line-num vis.win.selection.line)
    (var curr-line (. vis.win.file.lines line-num))
    ;; if curr-line ??? when curr-line ???
    (var yaml-path "")

    (when (check-line curr-line)
      (var (curr-indent is-seq) (get-indent curr-line))
      (var trigger-indent curr-indent)
      (var yaml-key (get-yaml-key curr-line))
      (when yaml-key
        (set yaml-path yaml-key)
        (while (> curr-indent 1)
          (set line-num (- line-num 1))
          (when (> line-num 0)
            (set curr-line (. vis.win.file.lines line-num))
            (when curr-line
              (when (check-line curr-line)
                (var seq-indicator "")
                (when is-seq
                  (set seq-indicator "[]"))
                (set (curr-indent is-seq) (get-indent curr-line))
                (when (< curr-indent trigger-indent)
                  (set trigger-indent curr-indent)
                  (set yaml-key (get-yaml-key curr-line))
                  (when yaml-key
                    (set yaml-path (string.format "%s%s.%s" yaml-key seq-indicator yaml-path))))))))))
    (vis:info yaml-path)
    yaml-path)
    "print yaml path")
