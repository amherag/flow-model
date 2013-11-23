(ql:quickload "ironclad")
(defpackage :utilities (:use :cl)
	    (:export hash-password
		     trim-white-space))
(in-package :utilities)

(defvar *salt* "W6Y$~U5viQiuHar_75?Kfz?29,;#+JK+&wY,ZL9^Z0I$Lob,Az8NZCcOyKcTP]O(")

(defun hash-password (password)
  (ironclad:byte-array-to-hex-string 
   (ironclad:digest-sequence 
    :sha256 
    (ironclad:ascii-string-to-byte-array (concatenate 'string password *salt*)))))

(defun trim-white-space (str)
  (string-trim '(#\Space #\Tab #\Newline) str))
