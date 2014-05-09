(defun org-export-non-greedy-select-tags (lst)
  "Workaround to export a .org file with headlines that contain
tags in `lst` AND headlines that have no tags"
  (let (all-buffer-tags results)
    (setq all-buffer-tags (apply #'append (org-get-buffer-tags)))
    (dolist (tag lst)
      (setq all-buffer-tags (delete tag all-buffer-tags))
      )
    (setq org-export-exclude-tags all-buffer-tags)  
    )
  )

(setq org-confirm-babel-evaluate nil)
(org-babel-lob-ingest "~/.briefs/babel.org")
