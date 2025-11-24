(local t (require :lib.faith))
(local {: validate} (require :falli))

(fn expect-valid [test]
  (t.= :valid test))

(fn expect-error [test]
  (t.= :error (. test 1)))

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
  (local schema [:table
                 [:name :string]
                 [:count :number]])

  (expect-valid (validate schema {:name "Dale" :count 5}))
  (t.= (validate schema {:n "Dale" :count 5}) {:name [:error "Expected missing field 'name'"]})
  (t.= (validate schema {:name 5 :count 5}) {:name ["error" "Expected type string for name. But actually received: 5"]})
  (expect-valid
   (validate [:table
              [:name :string]
              [:height :number]
              [:numbers [:list :number]]
              [:properties [:table [:one :string]]]]
             {:height 50
              :name "Okay"
              :numbers [5 4 3]
              :properties {:one "ok"}})))

(fn test-list []
  (expect-valid (validate [:list [:enum 1 2 3 4 :five]] [1 2 3 4 :five]))
  (expect-valid (validate [:list :number] [10 20 30 40 50]))
  (expect-valid (validate [:list [:table [:name :string]]]
                          [{:name "Joe"}
                           {:name "Jill"}
                           {:name "Jack"}]))
  )

(fn test-fn []
  (expect-valid (validate (fn [x] (< 0 x)) 1))
  (expect-valid (validate [:list (fn [x] (< 0 x))] [1 3 4])))

{: test-primitive-types : test-enum
 : test-table : test-list : test-fn}
