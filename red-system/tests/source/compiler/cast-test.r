REBOL [
	Title:   "Red/System cast test script"
	Author:  "Nenad Rakocevic & Peter W A Wood"
	File: 	 %cast-test.r
	Rights:  "Copyright (C) 2011 Nenad Rakocevic & Peter W A Wood. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

change-dir %../

compiled?: func [
  source [string!]
][
  write %runnable/cast.reds source 
  exe: --compile src: %runnable/cast.reds
  if exists? %runnable/cast.reds [delete %runnable/cast.reds]
  if all [
    exe
    exists? exe
  ][
    delete exe
  ]
  qt/compile-ok?
]
  

~~~start-file~~~ "cast-compile"

===start-group=== "compiler checks"

  --test-- "cast integer! 1"
  --assert compiled? {
      Red/System[]
      #"^^(00)" = as byte! 0
    }
    
  --test-- "cast logic! 1"
  --assert compiled? {
      Red/System[]
      #"^^(01)" = as byte! true
    }
    
  --test-- "cast logic! 2"
  --assert compiled? {
      Red/System[]
      #"^^(00)" = as byte! false
    }
    
  --test-- "cast c-string! 1"
  --assert compiled? {
      Red/System[]
      false = as logic! ""
   }
   
   --test-- "cast c-string! 2"
   --assert compiled? {
      Red/System[]
      csc7-struct: declare struct! [
        c1 [byte!]
        c2 [byte!]
        c3 [byte!]
        c4 [byte!]
        c5 [byte!]
      ]
      csc7-str: "Peter"
      csc7-struct: as [struct! [
        c1 [byte!] c2 [byte!] c3 [byte!] c4 [byte!] c5 [byte!]
      ]] csc7-str
    }
    
	--test-- "cast function! 1"
	--assert compiled? {
		Red/System[]
		foo: func [a [integer!]][]
		i: as integer! :foo
	}
 
 ===end-group===
 
 ===start-group=== "Warnings"
    
    warning-test: func[
      type [string!]
      src [string!]
    ][
      --test-- reform ["cast" type  "warning"]
      result: false
      result: compiled? src
      msg: "*** Warning: type casting from #type# to #type# is not necessary"
      warning: replace/all copy msg "#type#" type
       either result [
         --assert none <> find qt/comp-output warning 
       ][
          --assert result                       ;; signify failing test
          print qt/comp-output
       ]
    ]
       
    warning-test "byte!" {
        Red/System []
         b: #"A"
         #"A" = as byte! b
    }
    
    warning-test "integer!" {
        Red/System []
         i: 0
         0 = as integer! i
    }

  --test-- "logic! warning special case"
    result: false
    result: compiled? {
      Red/System []

      l: true
      true = as logic! l
    } 
    warning: "*** Warning: type casting"
    either result [
  --assert found? find qt/comp-output warning 
    ][
      --assert result                       ;; signify failing test
      print qt/comp-output
    ]
  
    warning-test "logic!" {
        Red/System []
         l: 1 = 1
         l2: as logic! l
    }


    warning-test "c-string!" {
        Red/System []
         cs: "hello"
         cs2: as c-string! cs
    }
    
    warning-test "pointer!" {
        Red/System []
         p:  declare pointer! [integer!]
         p1: declare pointer! [integer!]
         p: as [pointer! [integer!]] 1
         p1: p
         p1 = as [pointer! [integer!]] p
    }
    
    warning-test "struct!" {
        Red/System []
         s1: declare struct! [a [integer!] b [integer!]]
         s2: declare struct! [a [integer!] b [integer!]]
         s2 = as [struct! [a [integer!] b [integer!]]] s1
    }
        
===end-group=== 

===start-group=== "Errors"
 
	--test-- "cast function! error 1"
	--compile-this {
		foo: func [a [integer!]][]
		b: as byte! :foo
	}
	--assert-msg? "type casting from function! to byte! is not allowed"
	
	--test-- "cast function! error 2"
	--compile-this {
		foo: func [a [integer!]][]
		l: as logic! :foo
	}
	--assert-msg? "type casting from function! to logic! is not allowed"
	
	--test-- "cast function! error 3"
	--compile-this {
		foo: func [a [integer!]][]
		s: as c-string! :foo
	}
	--assert-msg? "type casting from function! to c-string! is not allowed"
       
~~~end-file~~~


