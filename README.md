# Introduction

Falli is a schema library for the fennel programming language.  It allows the user to define schemas and validate their data against the schemas.

# Description

Falli is inspired by malli (clojure schema library). Schemas are NOT intended to be used like types. These are best used at boundaries to validate data shapes.

# Usage 

## Primitive types 

```clojure
(local falli (require :falli))

(validate :number 5)
;; Returns :valid

(validate :boolean true)
;; Returns :valid

(validate :string "Hello!")
;; Returns :valid

(validate :string 5)
;; returns [:error "Expected type string for . But actually received: 5"]
```

## Enums

Enums are a "set of primitive (may change this later?) values"

```clojure
(validate [:enum "Hi" 5] "Hi")
;; :valid

(validate [:enum "Hi" 5] 5)
;; :valid

(validate [:enum "Hi" 5] 4)
;; [:error _]
```

## Table validation

Tables in this context refer to "maps" or fennel tables that have key values in them `{}`, lists are a different concept due to lua semantics, but only sort of because of lua semantics.

```clojure 
(local schema [:table 
                [:name :string]
				[:count :number]])

(validate schema {:name "Dale" :count 5})
;; :valid

(validate schema {:n "Dale" :count 5})
;;=> {:name [:error "Expected missing field 'name'"]}

(validate schema {:name 5 :count 5})
;;=> {:name ["error" "Expected type string for name. But actually received: 5"]}

(local schema2 [:table
                 [:name :string]
                 [:height :number]
                 [:numbers [:list :number]]
                 [:properties [:table [:one :string]]]])

(validate schema2 {:height 50
                   :name "Dan"
				   :numbers [5 4 3]
				   :properties {:one "ok"}})
;; :valid
```

### Optional fields

Fields can be made optional by adding the `:?` keyword 

`[:table [:name :? :string]]`

```clojure
(local schema [:table
                 [:name :string]
                 [:count :number]])

(validate schema {:name "Jen" :count 5})
;; :valid

(validate schema {:name "Jen"})
;; => {:count ["error" "Expected missing field 'count'"]}

(local schema2 [:table
                 [:name :string]
                 [:count :? :number] ;; :? makes this optional
                 ])

(validate schema2 {:name "Jen"})
;; :valid

```


## List

Lists and tables are the same in lua, however in fennel, these are distinguished syntactically. `[]` for "lists" `{}` for "tables".

The `:list` pattern ultimately takes in another schema and checks each element in the "list" to validate against that pattern


```clojure
(validate [:list :number] [10 20 30 40 50])
;; :valid

(validate [:list [:enum 1 2 3 4 :five]] [1 2 3 4 :five])
;; :valid

(validate [:list [:table [:name :string]]]
          [{:name "Joe"}
           {:name "Jill"}
           {:name "Jack"}])
```

## Function schema

If none of the above fit use case, you can fallback to adding functions as a schema

```clojure
(validate (fn [x] (< 0 x)) 1)
;; :valid
	
(validate [:list (fn [x] (< 0 x))] [1 3 4])
;; :valid

```





