(local t (require :lib.faith))
(local falli (require :falli))

(fn tests []
  (t.= (falli.validate :string "string") :valid)
  )
