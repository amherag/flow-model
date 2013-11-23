(ql:quickload "cl-json")
(ql:quickload "drakma")
(ql:quickload "cl-ppcre")
(defpackage :docker (:use :cl)
	    (:export
	     create-container
	     run-container))
(in-package :docker)

(setf drakma:*text-content-types* (cons '("application" . "json") drakma:*text-content-types*))
(setf drakma:*text-content-types* (cons '("application" . "vnd.docker.raw-stream") drakma:*text-content-types*))

(defparameter *url* "http://localhost:5555"
  "No trailing slash at the end!")

(defun get-containers (&optional (format "json"))
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/containers/json?all=1" *url*)
			:accept "application/json")))

(defun delete-container (container-id)
  (drakma:http-request (format nil "~a/containers/~a"
			       *url* container-id)
		       :method :delete
		       :accept "application/json"))

(defun create-container (&key (command "date") (tty t))
  (let* ((result (handler-case (json:decode-json-from-string
				(drakma:http-request
				 (format nil "~a/containers/create" *url*)
				 :method :post
				 :content-type "application/json"
				 :content (json:encode-json-to-string
					   `(("Hostname" . "")
					     ("User" . "")
					     ("Memory" . 0)
					     ("MemorySwap" . 0)
					     ("AttachStdin" . nil)
					     ("AttachStdout" . nil)
					     ("AttachStderr" . nil)
					     ("PortSpecs" . nil)
					     ("Privileged" . nil)
					     ("Tty" . ,tty)
					     ("OpenStdin" . nil)
					     ("StdinOnce" . nil)
					     ("Env" . nil)
					     ("Cmd" . ("/usr/bin/newlisp" "-e" ,command))
					     ("Dns" . nil)
					     ("Image" . "enjail/newlisp:10.3.4")
					     ("Volumes" . ())
					     ("VolumesFrom" . "")
					     ("WorkingDir" . "")))
				 ;;:parameters '(("name" . "testing"))
				 ))
		   (error (condition)
		     (values nil condition))))
	 (container-id (if result
			   (cdr (assoc :*ID result)))))
    container-id))

(defun run-container (container-id &key (auto-remove t))
  "Tiene problemas aun :( con los threads. Posible solucion: esperar a que termine el thread."
  (let (result)
    (bordeaux-threads:make-thread
	 (lambda ()
	   (setf result (attach-container container-id))))
    (dotimes (i 30)
      (start-container container-id)
      (if (and result (stringp result) (not (string= "" result)))
	  (return t)
	  (sleep 0.1)))
    (when auto-remove
	(sleep 0.1)
	(delete-container container-id))
    (string-trim '(#\Space #\Tab #\Newline #\Return) result)))

;;(time (run-container (create-container :command "(dotimes (x 100000) x)" :tty t)))

(defun attach-container (container-id)
   (drakma:http-request (format nil "~a/containers/~a/attach?stream=1&stderr=1&stdout=1" *url* container-id)
			:method :post
			;;:content-type "application/json"
			;;:content "{}"
			;;:want-stream t
			:accept "application/vnd.docker.raw-stream"))

(defun start-container (container-id)
   (drakma:http-request (format nil "~a/containers/~a/start" *url* container-id)
			:method :post
			;;:content-type "application/json"
			;;:content "{}"
			;;:accept "text/plain"
			))

(defun inspect-container (container-id)
  (json:decode-json-from-string (drakma:http-request (format nil "~a/containers/~a/json" *url* container-id)
						     :accept "application/json"
						     )))







(drakma:http-request (format nil "~a/containers/create" *url*)
		     :method :post
		     :content-type "application/json"
		     :content (json:encode-json-to-string
				    '(("Hostname" . "")
				      ("User" . "")
				      ("Memory" . 0)
				      ("MemorySwap" . 0)
				      ("AttachStdin" . nil)
				      ("AttachStdout" . t)
				      ("AttachStderr" . t)
				      ("PortSpecs" . nil)
				      ("Privileged" . nil)
				      ("Tty" . nil)
				      ("OpenStdin" . nil)
				      ("StdinOnce" . nil)
				      ("Env" . nil)
				      ("Cmd" . ("date"))
				      ("Dns" . nil)
				      ("Image" . "ubuntu:latest")
				      ("Volumes" . ())
				      ("VolumesFrom" . "")
				      ("WorkingDir" . "")
				      ))
		     :parameters '(("name" . "testing")))

(defun get-containers (&optional (format "json"))
  (json:decode-json-from-string
   (drakma:http-request (format nil "~a/containers/json?all=1" *url*)
			:method :get
			:content-type "application/json"
			:content (json:encode-json-to-string `((script . ,script)))
			:accept "application/json")))

(drakma:http-request "http://127.0.0.1:5555")
(drakma:http-request "http://127.0.0.1:5555/containers/json?all=1&before=8dfafdbc3a40&size=1")
(drakma:http-request "http://127.0.0.1:5555/containers/json?all=1")



(drakma:http-request "http://127.0.0.1:5555/containers/create" :method :post
		     :content-type "application/json"
		     :content "{
     \"Hostname\": \"\",
     \"User\": \"\",
     \"Memory\":0,
     \"MemorySwap\":0,
     \"AttachStdin\":false,
     \"AttachStdout\":true,
     \"AttachStderr\":true,
     \"PortSpecs\":null,
     \"Privileged\": false,
     \"Tty\":false,
     \"OpenStdin\":false,
     \"StdinOnce\":false,
     \"Env\":null,
     \"Cmd\":[
             \"/usr/bin/echo 5\"
     ],
     \"Dns\": null,
     \"Image\": \"ubuntu:latest\",
     \"Volumes\":{},
     \"VolumesFrom\": \"\",
     \"WorkingDir\": \"\",
     \"AutoRemove\": true

}"
		     :parameters '(("name" . "testing")))

(flexi-streams:octets-to-string #(123 34 73 100 34 58 34 48 56 52 101 53 51 51 53 49 97 98 57 34 125))

(drakma:http-request "http://127.0.0.1:5555/images/json")

(drakma:http-request "http://127.0.0.1:5555/images/create?fromImage=ubuntu" :method :post)
