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



