(local t (require :lib.faith))

(local default-modules [:test.tests])

(t.run (if (= 0 (length arg)) default-modules arg))
