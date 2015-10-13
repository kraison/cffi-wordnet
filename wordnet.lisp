(in-package #:cffi-wordnet)

(defun wordnet-init ()
  (wninit))

(defun get-synset-words (synset)
  (let ((result nil))
    (dotimes (i (cffi:foreign-slot-value synset '(:struct Synset) 'wcount))
      (push
       (cffi:mem-aref (cffi:foreign-slot-value synset '(:struct Synset) 'words) :string i)
       result))
    (mapcar (lambda (word)
              (cl-ppcre:regex-replace-all "_" (string-downcase word) " "))
            (nreverse result))))

(defun get-synset-definition (synset)
  (cffi:foreign-slot-value synset '(:struct Synset) 'defn))

(defun wordnet-search (word &key (part-of-speech +noun+) (sense +all-senses+)
		       (search-type +synonyms+))
  (let ((synset (findtheinfo_ds word part-of-speech search-type sense))
	(words nil))
    (unwind-protect
	 (let ((ss synset))
	   (loop
	      (if (and (pointerp ss) (null-pointer-p ss))
		  (return)
                  (progn
                    (push (get-synset-words ss) words)
                    (setq ss (cffi:foreign-slot-value ss '(:struct Synset) 'nextss))))))
      (free_syns synset))
    (mapcar (lambda (set)
              (remove-duplicates
               (mapcar (lambda (word)
                         (cl-ppcre:regex-replace-all "_" (string-downcase word) " "))
                       set)
               :test 'string=))
            (reverse words))))

(defstruct (synset-vertex
             (:print-function
              (lambda (v s d)
                (declare (ignore d))
                (format s "~{~A~^, ~}" (word-list v))))
             (:conc-name nil))
  word-list)

(defun walk-up-hypernym-tree (synset graph root &optional (spaces 0))
  (let ((pointer-count (cffi:foreign-slot-value synset '(:struct Synset) 'ptrcount)))
    ;;(dotimes (i spaces) (format t " "))
    ;;(format t "~S~%" (get-synset-words synset))
    (let* ((words (get-synset-words synset))
           (vertex (add-node graph (make-synset-vertex :word-list words))))
      (add-edge graph root vertex :edge-type :has-hypernym)
      (dotimes (i pointer-count)
        (handler-case
            (let ((this-ptrtype (cffi:mem-aref (cffi:foreign-slot-value synset '(:struct Synset) 'ptrtyp) :int i))
                  (this-ppos (cffi:mem-aref (cffi:foreign-slot-value synset '(:struct Synset) 'ppos) :int i))
                  (this-ptroff (cffi:mem-aref (cffi:foreign-slot-value synset '(:struct Synset) 'ptroff) :long i)))
              (when (or (eq this-ptrtype HYPERPTR)
                        (eq this-ptrtype INSTANCE))
                (let ((synset1 (read_synset this-ppos this-ptroff "")))
                  (unwind-protect
                       (walk-up-hypernym-tree synset1 graph vertex (+ 2 spaces))
                  (free_syns synset1)))))
        (error (e)
          (dotimes (i spaces) (format t " "))
          (format t "GOT ERROR '~A'~%~%" e)))))))

(defun hypernym-graph (word &key (part-of-speech +noun+) (sense +all-senses+)
                              graph root)
  (let ((synset (findtheinfo_ds (or (morphword word part-of-speech) word)
                                part-of-speech
                                +hypernym+
                                sense)))
    (unless graph
      (setq graph (make-typed-graph :node-comparator #'equalp)))
    (unless root
      (setq root (add-node graph word)))
    (unwind-protect
         (loop until (or (null synset)
                         (and (pointerp synset) (null-pointer-p synset))) do
              (walk-up-hypernym-tree synset graph root)
              (let ((next-synset (cffi:foreign-slot-value synset '(:struct Synset) 'nextss)))
                ;;(free_syns synset)
                (setq synset next-synset)))
      (free_syns synset))
    (values graph root)))

(defun test ()
  (wninit)
  (format t "~A~%" (findtheinfo "block" VERB SYNS ALLSENSES))
  (let ((synset (findtheinfo_ds "block" VERB MERONYM ALLSENSES)))
    (unwind-protect
	 (progn
	   (format t "Sense 1, words: ~A~%"
		   (cffi:foreign-slot-value synset 'Synset 'wcount))
	   (get-synset-words synset))
      (free_syns synset))))
