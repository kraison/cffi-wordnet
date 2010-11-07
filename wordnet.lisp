(in-package #:cffi-wordnet)

(defun get-synset-words (synset)
  (let ((result nil))
    (dotimes (i (cffi:foreign-slot-value synset 'Synset 'wcount))
      (push
       (cffi:mem-aref (cffi:foreign-slot-value synset 'Synset 'words) :string i)
       result))
    result))

(defun wordnet-init ()
  (wninit))

(defun wordnet-search (word &key (part-of-speech +noun+) (sense +all-senses+)
		       (search-type +synonyms+))
  (let ((synset (findtheinfo_ds word part-of-speech search-type sense))
	(words nil))
    (unwind-protect
	 (let ((ss synset))
	   (loop
	      (if (and (pointerp ss) (null-pointer-p ss))
		  (return)
		  (setq words (nconc words (get-synset-words ss))
			ss (cffi:foreign-slot-value ss 'Synset 'nextss)))))
      (free_syns synset))
    (remove-duplicates
     (mapcar #'(lambda (word)
		 (cl-ppcre:regex-replace-all "_" (string-downcase word) " "))
	     words)
     :test 'string=)))

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

