(local t (require :lib.faith))
(local {: validate} (require :falli))

(fn test-primitive-types []
  (t.= (validate :string "Hello World") :valid)
  (t.= (validate :number 5) :valid)
  (t.= (validate :boolean true) :valid)
  (t.= (validate :string 5)
       [:error "Expected type string for . But actually received: 5"])
  (t.= :valid (validate :nil nil)))

(fn test-enum []
  (t.= :valid (validate [:enum "Hi" 5] "Hi"))
  (t.= :valid (validate [:enum "Hi" 5] 5))
  (t.= (validate [:enum "Hi" 5] 4)
       ["error" "Expected one of value [Hi, 5] for . Actual was: 4"]))

(fn test-table []
  (local schema [:table [:name :string]])
  (t.= (validate schema {:name "Dale"}))


  )

;; (comment 
;;  (local tests 
;;         [(validate :string "Hello")
;;          (validate :number 5)
;;          (validate :boolean true)
;;          (validate :nil nil)
;;          (validate [:enum "Hi" 5] "Hi")
;;          (validate [:table [:name :string]] {:name "Dale"})
;;          (validate [:table
;;                     [:name :string]
;;                     [:height :number]
;;                     [:numbers [:list :number]]
;;                     [:properties [:table [:one :string]]]]
;;                    {:height 50
;;                     :name "Okay"
;;                     :numbers [5]
;;                     :properties {:one "ok"}})
;;          (validate [:list [:enum 1 2 3 4 :five]] [1 2 3 4 :five])

;;          (validate [:table [:name :? :string]] {})
;;          (validate (fn [x] (< 0 x)) 1)
;;          (validate [:list (fn [x] (< 0 x))] [1 3 4])
;;          (validate [:table [:count (fn [x] (< 0 x))]] {:count 3})
;;          (validate :table [])])

;;  (each [_ t (pairs tests)]
;;    (assert (= :valid t) "error")))
{: test-primitive-types : test-enum}
