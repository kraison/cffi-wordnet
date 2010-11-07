(in-package #:cl-user)

(defpackage #:cffi-wordnet
  (:use #:cl #:cffi)
  (:export #:wordnet-init
	   #:wordnet-search))
