(fn contains? [xs val]
  (when xs 
    (var found nil)
    (each [_ x (pairs xs) &until found]
      (when (= x val)
        (set found true)))
    found))

(fn validate [schema value ?value-name]
  (case schema
    [:table & schema-fields]
    (if (= :table (type value))
        (let [table-res {}]
          (each [_ schema-field (ipairs schema-fields)]
            (let [[field-name sub-schema] schema-field
                  field-name (. schema-field 1)
                  optional? (when (<= 3 (length schema-field))
                              (= :? (. schema-field 2)))
                  sub-schema (. schema-field (length schema-field))

                  validation-result 
                  (case (?. value field-name)
                    field-value (validate sub-schema field-value field-name)
                    (where nil optional?) :valid
                    nil [:error (.. "Expected missing field '" field-name "'")])]
              (case validation-result
                :valid nil
                _ (set (. table-res field-name) validation-result)
                )))
          (if (= nil (next table-res))
              :valid
              table-res))

        [:error (.. "Expected type table for "
                    (or ?value-name "")
                    ". But actually received: "
                    (or value "nil"))]) 

    [:list sub-schema]
    (if (= :table (type value))
        (let [list-result 
              (icollect [i v (ipairs value)]
                (let [result (validate sub-schema v (.. "index " i))]
                  (case result
                    [:error _] result
                    :valid nil)))]
          (if (< 0 (length list-result))
              list-result
              :valid)
          )
        [:error (.. "Expected type list (table) "
                    (or ?value-name "")
                    ". But actually received: "
                    (or value "nil"))]) 

    [:enum & vals]
    (if (contains? vals value)
        :valid
        [:error (.. "Expected one of value [" (table.concat vals ", ") "] for "
                    (or ?value-name "")
                    ". Actual was: " value)])
    
    :nil 
    (if
     (= value nil)
     :valid
     [:error 
      (.. "Expected type nil for "
          (or ?value-name "")
          ". But actually received: "
          (or value "nil"))])

    (where f (= :function (type f)))
    (if (f value)
        :valid
        [:error (.. "Value does not match function for "
                    (or ?value-name ""))])

    schema-type
    (if (and value (= schema-type (type value)))
        :valid
        [:error (.. "Expected type "
                    schema-type
                    " for "
                    (or ?value-name "")
                    ". But actually received: "
                    value)])))

(comment 
 (local tests 
        [(validate :string "Hello")
         (validate :number 5)
         (validate :boolean true)
         (validate :nil nil)
         (validate [:enum "Hi" 5] "Hi")
         (validate [:table [:name :string]] {:name "Dale"})
         (validate [:table
                    [:name :string]
                    [:height :number]
                    [:numbers [:list :number]]
                    [:properties [:table [:one :string]]]]
                   {:height 50
                    :name "Okay"
                    :numbers [5]
                    :properties {:one "ok"}})
         (validate [:list [:enum 1 2 3 4 :five]] [1 2 3 4 :five])

         (validate [:table [:name :? :string]] {})
         (validate (fn [x] (< 0 x)) 1)
         (validate [:list (fn [x] (< 0 x))] [1 3 4])
         (validate [:table [:count (fn [x] (< 0 x))]] {:count 3})
         (validate :table [])

         ])
 (each [_ t (pairs tests)]
   (assert (= :valid t) "error"))

 )


{: validate}
