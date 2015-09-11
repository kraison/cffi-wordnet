(in-package #:cl-user)

(defpackage #:cffi-wordnet
  (:use #:cl #:cffi)
  (:nicknames #:wordnet)
  (:export #:wordnet-init
	   #:wordnet-search
           #:morphword
	   #:+noun+
	   #:+verb+
	   #:+adjective+
	   #:+adverb+
	   #:+all-senses+
	   #:+synonyms+
           #:+holonym+
           #:+meronym+))
