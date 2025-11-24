;; https://github.com/trevorcode/falli

;; MIT License

;; Copyright (c) 2025 trevorcode

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

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



{: validate}
