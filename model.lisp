(ql:quickload "sqlite")
(ql:quickload "cl-redis")
(ql:quickload "ironclad")
(defpackage :model (:use :cl :redis)
	    (:export connect-db
		     disconnect-db
		     get-user/password
		     get-solution
		     post-result
		     get-exercises
		     post-user
		     post-exercise
		     hash-password
		     ))
(in-package :model)

(defvar *salt* "W6Y$~U5viQiuHar_75?Kfz?29,;#+JK+&wY,ZL9^Z0I$Lob,Az8NZCcOyKcTP]O(")

(defun hash-password (password)
  (ironclad:byte-array-to-hex-string 
   (ironclad:digest-sequence 
    :sha256 
    (ironclad:ascii-string-to-byte-array (concatenate 'string password *salt*)))))

(defun get-user/password (username)
  (sqlite:execute-single *db* "SELECT password FROM users WHERE username = ?" username))

(defun post-exercise (step title exercise solution &optional (coding nil))
  (sqlite:execute-non-query *db* "INSERT INTO exercises (step, title, content, coding, solution) VALUES (?, ?, ?, ?, ?)"
			    step title exercise (if coding "true" "false") solution))

(defun get-solution (step)
  (sqlite:execute-single *db* "SELECT solution FROM exercises WHERE step = ?" step))

;;(get-solution "#step-1")

(defun get-exercises ()
  "It gets ALL the exercises for now."
  (sqlite:execute-to-list *db* "SELECT * FROM exercises ORDER BY step"))

;;(get-exercises)

(let ((connected? nil))
  "Very basic singleton."

  (defun disconnect-db ()
    (when connected?
      (sqlite:disconnect *db*)
      (setf connected? nil)))

  (defun connect-db (&optional (path "db.sqlite"))
    (when (not connected?)
      (defparameter *db* (sqlite:connect path))
      (setf connected? t))))

(defun post-result (result)
  ;;(sqlite:execute-non-query *db* "INSERT INTO results(result) VALUES (?)" result)
  (red-set (random 99999999999) result))

;;(connect-db)
;;(disconnect-db)

(defun init-db ()
  (sqlite:execute-non-query *db* "CREATE TABLE results(result text)")
  (sqlite:execute-non-query *db* "CREATE TABLE exercises(step integer, title text, content text, coding bool, solution text)"))

;;(red-save)

;;(init-db)

;;(redis:connect)
;;(redis:disconnect)
(connect-db)

;;(apply #'redis:red-mget (redis:red-keys "*"))
;;(redis:red-hgetall "63401152795")
;;(redis:red-mget 
