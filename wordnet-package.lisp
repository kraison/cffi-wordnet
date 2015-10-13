(in-package #:cl-user)

(defpackage #:cffi-wordnet
  (:use #:cl #:cffi #:graph-utils)
  (:nicknames #:wordnet)
  (:export #:wordnet-init
	   #:wordnet-search
           #:morphword
           #:hypernym-graph
	   #:+noun+
	   #:+verb+
	   #:+adjective+
	   #:+adverb+
	   #:+all-senses+
	   #:+synonyms+
           #:+holonym+
           #:+hypernym+
           #:+meronym+))
