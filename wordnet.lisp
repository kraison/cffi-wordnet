(in-package #:cffi-wordnet)

(defun get-synset-words (synset)
  (let ((result nil))
    (dotimes (i (cffi:foreign-slot-value synset 'Synset 'wcount))
      (push
       (cffi:mem-aref (cffi:foreign-slot-value synset 'Synset 'words) :string i)
       result))
    result))

(defun test ()
  (wninit)
  (format t "~A~%" (findtheinfo "block" VERB SYNS ALLSENSES))
  (let ((synset (findtheinfo_ds "block" VERB SYNS ALLSENSES)))
    (unwind-protect
	 (progn
	   (format t "Sense 1, words: ~A~%" 
		   (cffi:foreign-slot-value synset 'Synset 'wcount))
	   (get-synset-words synset))
      (free_syns synset))))
